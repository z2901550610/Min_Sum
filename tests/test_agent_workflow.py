from __future__ import annotations

import importlib.util
import json
import os
import subprocess
import sys
from pathlib import Path

import pytest
import yaml


REPO_ROOT = Path(__file__).resolve().parents[1]


def load_script(name: str):
    path = REPO_ROOT / "scripts" / f"{name}.py"
    scripts_path = str(path.parent)
    if scripts_path not in sys.path:
        sys.path.insert(0, scripts_path)
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


def write_fake_sby(path: Path) -> None:
    path.write_text(
        "#!/bin/sh\n"
        "if [ \"$1\" = \"--version\" ]; then echo 'fake-sby 1.0'; exit 0; fi\n"
        "echo 'SBY engine output that stays in the log'\n"
        "if [ \"$FAKE_SBY_FAIL\" = \"1\" ]; then echo 'ERROR: injected failure'; exit 1; fi\n"
        "echo 'DONE (PASS, rc=0)'\n",
        encoding="utf-8",
    )
    path.chmod(0o755)


def run_wrapper(tmp_path: Path, *, fail: bool) -> subprocess.CompletedProcess[str]:
    fake_sby = tmp_path / "fake-sby"
    write_fake_sby(fake_sby)
    (tmp_path / "dut.sv").write_text("module dut; endmodule\n", encoding="utf-8")
    (tmp_path / "proof.sby").write_text("[files]\ndut.sv\n", encoding="utf-8")
    environment = os.environ.copy()
    environment.update(
        {
            "REAL_SBY": str(fake_sby),
            "SBY_LOG_DIR": str(tmp_path / "logs"),
            "CHECK_SUMMARY_PATH": str(tmp_path / "results" / "check-summary.json"),
            "VALIDATION_RUN_ID": "wrapper-test",
            "VALIDATION_EVENTS_PATH": str(tmp_path / "results" / "events.jsonl"),
            "FAKE_SBY_FAIL": "1" if fail else "0",
        }
    )
    return subprocess.run(
        [
            sys.executable,
            str(REPO_ROOT / "scripts" / "sby_quiet.py"),
            "-f",
            "-d",
            str(tmp_path / "formal"),
            "proof.sby",
            "prove",
        ],
        cwd=tmp_path,
        env=environment,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )


def test_sby_quiet_pass_records_full_log_and_summary(tmp_path: Path) -> None:
    result = run_wrapper(tmp_path, fail=False)
    assert result.returncode == 0
    assert "sby PASS: proof.sby prove" in result.stdout
    assert "engine output" not in result.stdout
    log_text = next((tmp_path / "logs").glob("*.log")).read_text(encoding="utf-8")
    assert "engine output that stays in the log" in log_text
    summary = json.loads(
        (tmp_path / "results" / "check-summary.json").read_text(encoding="utf-8")
    )
    recorded = summary["results"][0]
    assert recorded["status"] == "PASS"
    assert recorded["task"] == "prove"
    assert recorded["tool"]["version"] == "fake-sby 1.0"
    assert recorded["source_digest"]
    event = json.loads(
        (tmp_path / "results" / "events.jsonl").read_text(encoding="utf-8").strip()
    )
    assert event["evidence_layer"] == "formal"
    assert event["status"] == "PASS"
    assert event["run_id"] == "wrapper-test"
    assert "event_id" not in event


def test_sby_quiet_failure_preserves_return_code_and_diagnostics(tmp_path: Path) -> None:
    result = run_wrapper(tmp_path, fail=True)
    assert result.returncode == 1
    assert "sby FAIL: proof.sby prove" in result.stdout
    assert "ERROR: injected failure" in result.stderr
    summary = json.loads(
        (tmp_path / "results" / "check-summary.json").read_text(encoding="utf-8")
    )
    assert summary["results"][0]["status"] == "FAIL"


def test_check_plan_routes_formal_and_workflow_changes() -> None:
    check_plan = load_script("check_plan")
    plan = check_plan.build_plan(
        [
            "Makefile",
            "formal/trike_ct_verify_stream.sby",
            "scripts/sby_quiet.py",
        ]
    )
    profile_ids = [profile["id"] for profile in plan["profiles"]]
    assert "tool_entry" in profile_ids
    assert "workflow" in profile_ids
    assert "formal" in profile_ids
    assert "make validate-workflow" in plan["commands"]
    assert "make check" not in plan["commands"]
    assert "make formal-ct-control" not in plan["commands"]
    assert "make formal-fast" not in plan["commands"]
    assert plan["release_commands"] == []
    assert plan["read_only"] is True


def test_check_plan_self_routes_workflow_and_scopes_hardware_tokens() -> None:
    check_plan = load_script("check_plan")
    config_plan = check_plan.build_plan(["config/validation_profiles.toml"])
    assert [profile["id"] for profile in config_plan["profiles"]] == [
        "tool_entry",
        "workflow",
    ]
    assert config_plan["commands"] == [
        "git diff --check -- config/validation_profiles.toml",
        "make validate-workflow",
    ]

    test_plan = check_plan.build_plan(["tests/test_agent_workflow.py"])
    assert [profile["id"] for profile in test_plan["profiles"]] == ["workflow"]
    assert test_plan["commands"] == [
        "git diff --check -- tests/test_agent_workflow.py",
        "make check-agent-workflow",
    ]
    assert test_plan["release_commands"] == []

    documentation_plan = check_plan.build_plan(
        ["docs/k_sign_notes.md", "docs/parameter_notes.md"]
    )
    assert [profile["id"] for profile in documentation_plan["profiles"]] == ["records"]
    assert documentation_plan["commands"] == [
        "git diff --check -- docs/k_sign_notes.md docs/parameter_notes.md",
        "make check-records",
    ]

    dependency_plan = check_plan.build_plan(["pyproject.toml"])
    assert dependency_plan["commands"] == [
        "git diff --check -- pyproject.toml",
        "make python-sync validate-workflow",
    ]

    scoped = subprocess.run(
        [
            "make",
            "check-plan",
            "VALIDATION_PATHS=rtl/reset_sync.sv tb/tb_reset_sync.sv",
        ],
        cwd=REPO_ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    assert scoped.returncode == 0
    assert "Validation plan: 2 changed path(s)" in scoped.stdout
    assert "make check-rtl test-reset-sync" in scoped.stdout


def test_check_plan_uses_owning_targets_before_aggregate_gates() -> None:
    check_plan = load_script("check_plan")

    formal_plan = check_plan.build_plan(["formal/tile_scheduler_formal.sv"])
    assert [profile["id"] for profile in formal_plan["profiles"]] == ["formal"]
    assert formal_plan["commands"] == [
        "git diff --check -- formal/tile_scheduler_formal.sv",
        "make formal-tile-scheduler",
    ]
    assert formal_plan["release_commands"] == ["make formal-fast"]

    ram_plan = check_plan.build_plan(["rtl/ram_i.sv"])
    assert [profile["id"] for profile in ram_plan["profiles"]] == [
        "local_rtl",
        "decoder",
    ]
    assert ram_plan["commands"] == [
        "git diff --check -- rtl/ram_i.sv",
        "make check-rtl test-ram-i",
    ]
    assert ram_plan["release_commands"] == ["make ci-fast"]

    kem_plan = check_plan.build_plan(["rtl/kem_ct_compare_select.sv"])
    assert kem_plan["commands"] == [
        "git diff --check -- rtl/kem_ct_compare_select.sv",
        "make check-rtl test-kem-ct-compare-select formal-ct-select",
    ]
    assert kem_plan["release_commands"] == ["make ci-kem-reference"]


def test_check_plan_command_coverage_keeps_manual_evidence_requirements() -> None:
    check_plan = load_script("check_plan")
    plan = check_plan.build_plan(
        [
            "scripts/run_validation.py",
            "rtl/decoder_top.sv",
            "formal/tile_scheduler.sby",
        ]
    )
    assert plan["commands"] == [
        "git diff --check -- scripts/run_validation.py rtl/decoder_top.sv formal/tile_scheduler.sby",
        "make validate-workflow",
    ]
    assert "make formal-tile-scheduler" not in plan["commands"]
    assert plan["manual_requirements"] == [
        "Run the smallest deterministic test that owns the changed behavior.",
        "If shared scheduling, geometry, or fixed cycles changed, run affected K=3/K=4 profiles and record the boundaries.",
        "Report harness boundary, assumptions, parameters, and unreachable states.",
    ]


def test_ci_nightly_dry_run_does_not_repeat_fast_formal_harnesses() -> None:
    result = subprocess.run(
        ["make", "-n", "ci-nightly"],
        cwd=REPO_ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    assert result.returncode == 0
    for project in (
        "formal/k_sign_overlap_scheduler.sby",
        "formal/kem_ct_compare_select.sby",
        "formal/tile_scheduler.sby",
        "formal/trike_kem_operation_control.sby",
        "formal/trike_poly_divstep_s1.sby",
    ):
        assert result.stdout.count(project) == 1
    assert result.stdout.count("formal/trike_ct_verify_stream.sby") == 2


def test_regress_is_only_the_fixed_seed_random_smoke() -> None:
    result = subprocess.run(
        ["make", "-n", "regress"],
        cwd=REPO_ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    assert result.returncode == 0
    assert "ci-fast" not in result.stdout
    assert "formal/" not in result.stdout
    assert result.stdout.count("scripts/run_bike_random.py") == 4


def test_rtl_gate_does_not_validate_workflow_itself() -> None:
    makefile = (REPO_ROOT / "Makefile").read_text(encoding="utf-8")
    check_line = next(line for line in makefile.splitlines() if line.startswith("check:"))
    ci_fast_line = next(
        line for line in makefile.splitlines() if line.startswith("ci-fast:")
    )
    assert "workflow-smoke" not in check_line
    assert "check-agent-workflow" not in ci_fast_line


def test_verilator_tests_use_target_scoped_build_directories() -> None:
    makefile = (REPO_ROOT / "Makefile").read_text(encoding="utf-8")
    assert "obj_dir/" not in makefile
    kem_aggregate = makefile.split("test-kem-unit:", 1)[1].split("\n\n", 1)[0]
    assert kem_aggregate == " $(KEM_UNIT_TARGETS)"

    result = subprocess.run(
        ["make", "-n", "test-ram-i", "test-ram-m", "test-kem-unit"],
        cwd=REPO_ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    assert result.returncode == 0
    compile_lines = [
        line
        for line in result.stdout.splitlines()
        if "scripts/verilator_quiet.py" in line and "--binary" in line
    ]
    assert compile_lines
    assert all(" --Mdir build/verilator/" in line for line in compile_lines)
    build_directories = []
    for line in compile_lines:
        words = line.split()
        build_directories.append(words[words.index("--Mdir") + 1])
    assert len(build_directories) == len(set(build_directories))
    assert all("/test-kem-unit/" not in path for path in build_directories)
    assert "build/verilator/test-ram-i/" in result.stdout
    assert "build/verilator/test-ram-m/" in result.stdout
    assert "build/verilator/test-trike-encaps-uv-core/" in result.stdout
    assert (
        "build/verilator/test-trike-encaps-uv-core-external-store/"
        in result.stdout
    )
    assert "build/verilator/test-trike-keygen-arith-core/" in result.stdout
    assert (
        "build/verilator/test-trike-keygen-arith-core-external-result-store/"
        in result.stdout
    )
    assert (
        "build/verilator/test-trike-keygen-arith-core-external-stores/"
        in result.stdout
    )
    assert result.stdout.count("--top-module tb_sm3_compress") == 1
    assert result.stdout.count("--top-module tb_sm3_hash_stream") == 1


def test_verilator_logs_are_atomically_unique_per_target(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    wrapper = load_script("verilator_quiet")
    monkeypatch.setenv("VERILATOR_LOG_DIR", str(tmp_path))
    first = wrapper.log_path(
        [
            "--Mdir",
            "build/verilator/test-variant-a/default",
            "--top-module",
            "tb_shared",
        ]
    )
    second = wrapper.log_path(
        [
            "--Mdir",
            "build/verilator/test-variant-b/default",
            "--top-module",
            "tb_shared",
        ]
    )
    assert first != second
    assert "test-variant-a-tb_shared" in first.name
    assert "test-variant-b-tb_shared" in second.name
    assert first.exists()
    assert second.exists()


def test_check_plan_routes_kem_units_without_aggregate_replay() -> None:
    check_plan = load_script("check_plan")

    implementation_plan = check_plan.build_plan(["rtl/trike_encaps_uv_core.sv"])
    assert implementation_plan["commands"] == [
        "git diff --check -- rtl/trike_encaps_uv_core.sv",
        "make check-rtl test-trike-encaps-uv-core test-trike-encaps-uv-core-external-store",
    ]
    assert implementation_plan["release_commands"] == ["make ci-kem-reference"]

    runtime_tb_plan = check_plan.build_plan(
        ["tb/tb_trike_pseudohash512_runtime.sv"]
    )
    assert runtime_tb_plan["commands"] == [
        "git diff --check -- tb/tb_trike_pseudohash512_runtime.sv",
        "make check-rtl test-trike-pseudohash-runtime",
    ]
    assert "make test-kem-unit" not in runtime_tb_plan["commands"]

    reference_plan = check_plan.build_plan(
        ["tb/tb_trike_keygen_secret_sampler_schedule.sv"]
    )
    assert reference_plan["commands"] == [
        "git diff --check -- tb/tb_trike_keygen_secret_sampler_schedule.sv",
        "make check-rtl test-trike-keygen-secret-schedule-reference",
    ]
    assert "make ci-kem-reference" not in reference_plan["commands"]


def test_each_named_test_target_has_at_most_one_verilator_compile() -> None:
    makefile = (REPO_ROOT / "Makefile").read_text(encoding="utf-8")
    compile_counts: dict[str, int] = {}
    target = ""
    for line in makefile.splitlines():
        if line and not line[0].isspace() and ":" in line:
            target = line.split(":", 1)[0]
            continue
        if (
            target.startswith("test-")
            and line.startswith("\t")
            and "$(VERILATOR)" in line
            and "--top-module" in line
        ):
            compile_counts[target] = compile_counts.get(target, 0) + 1
    assert compile_counts
    assert {name: count for name, count in compile_counts.items() if count > 1} == {}


def test_reference_variants_have_unique_direct_build_directories() -> None:
    result = subprocess.run(
        [
            "make",
            "-n",
            "test-trike-keygen-secret-reference",
            "test-trike-keygen-core-reference",
            "test-trike-decaps-postprocess-reference",
            "test-trike-decaps-syndrome-reference",
            "test-trike-encaps-core-reference",
        ],
        cwd=REPO_ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    assert result.returncode == 0
    compile_lines = [
        line
        for line in result.stdout.splitlines()
        if "scripts/verilator_quiet.py" in line and "--binary" in line
    ]
    build_directories = []
    for line in compile_lines:
        words = line.split()
        build_directories.append(words[words.index("--Mdir") + 1])
    assert len(build_directories) == 14
    assert len(build_directories) == len(set(build_directories))
    for aggregate in (
        "test-trike-keygen-secret-reference",
        "test-trike-keygen-core-reference",
        "test-trike-decaps-postprocess-reference",
        "test-trike-decaps-syndrome-reference",
        "test-trike-encaps-core-reference",
    ):
        assert f"build/verilator/{aggregate}/" not in result.stdout


def test_validation_profiles_drive_routing_and_generated_matrix(tmp_path: Path) -> None:
    profiles = load_script("validation_profiles")
    renderer = load_script("render_validation_matrix")
    config = profiles.load_profiles()
    assert config.profile_order == (
        "records",
        "tool_entry",
        "workflow",
        "local_rtl",
        "decoder",
        "public_params",
        "kem",
        "formal",
        "physical",
    )
    selected, owners, manual = profiles.classify_paths(
        ["docs/removed-record.md", "formal/trike_ct_verify_stream_formal.sv"],
        config,
    )
    assert selected == ["records", "formal"]
    assert [action.targets for action in owners] == [("formal-ct-control",)]
    assert [action.covers_profiles for action in owners] == [("formal",)]
    assert manual == []

    document_path = REPO_ROOT / "docs" / "verification" / "validation_matrix.md"
    document = document_path.read_text(encoding="utf-8")
    assert renderer.render_document(
        document, profiles.render_profile_table(config)
    ) == document

    stale_document = tmp_path / "validation_matrix.md"
    stale_document.write_text(
        document.replace("纯文档、实验索引或Vivado manifest", "stale row", 1),
        encoding="utf-8",
    )
    result = subprocess.run(
        [
            sys.executable,
            str(REPO_ROOT / "scripts" / "render_validation_matrix.py"),
            "--check",
            "--document",
            str(stale_document),
        ],
        cwd=REPO_ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 1
    assert "generated table is stale" in result.stderr


def test_validation_profile_schema_stores_targets_not_shell_commands() -> None:
    source = (
        REPO_ROOT / "config" / "validation_profiles.toml"
    ).read_text(encoding="utf-8")
    assert "schema_version = 3" in source
    assert "[[owners]]" in source
    assert "[[targeted_rules]]" not in source
    assert "commands =" not in source
    assert '"make ' not in source


def test_validation_profiles_route_every_repository_file() -> None:
    profiles = load_script("validation_profiles")
    config = profiles.load_profiles()
    paths = subprocess.run(
        ["git", "ls-files", "--cached", "--others", "--exclude-standard"],
        cwd=REPO_ROOT,
        check=True,
        text=True,
        stdout=subprocess.PIPE,
    ).stdout.splitlines()
    unrouted = []
    for path in paths:
        selected, owners, manual = profiles.classify_paths([path], config)
        if not selected and not owners and not manual:
            unrouted.append(path)
    assert unrouted == []


def test_validation_profile_repository_bindings_are_live() -> None:
    profiles = load_script("validation_profiles")
    config = profiles.load_profiles()
    assert profiles.repository_binding_errors(config) == []


def test_hardware_sources_have_at_most_one_owner() -> None:
    profiles = load_script("validation_profiles")
    config = profiles.load_profiles()
    for path in profiles.repository_paths():
        if not path.startswith(("rtl/", "tb/", "formal/")) or not path.endswith(
            (".sv", ".sby")
        ):
            continue
        _, owners, _ = profiles.classify_paths([path], config)
        assert len(owners) <= 1, path


def test_public_parameter_and_kem_aggregate_plans_do_not_repeat_static_gate() -> None:
    check_plan = load_script("check_plan")
    decoder_plan = check_plan.build_plan(["rtl/decoder_profile_config.sv"])
    assert decoder_plan["commands"] == [
        "git diff --check -- rtl/decoder_profile_config.sv",
        "make ci-smoke",
    ]
    assert "public_params" in [profile["id"] for profile in decoder_plan["profiles"]]

    trike_plan = check_plan.build_plan(["rtl/trike_decaps_profile_config.sv"])
    assert trike_plan["commands"] == [
        "git diff --check -- rtl/trike_decaps_profile_config.sv",
        "make ci-smoke test-trike-decaps-runtime-four-profile-reference",
    ]
    assert all(command != "make check-rtl" for command in trike_plan["commands"])

    asic_plan = check_plan.build_plan(["rtl/trike_kem_asic_top.sv"])
    assert asic_plan["commands"] == [
        "git diff --check -- rtl/trike_kem_asic_top.sv",
        "make ci-kem-reference",
    ]


def test_validation_profile_allows_missing_owner_and_rejects_multiple(
    tmp_path: Path,
) -> None:
    profiles = load_script("validation_profiles")
    source = profiles.DEFAULT_CONFIG_PATH.read_text(encoding="utf-8")

    missing_path = tmp_path / "missing-owner.toml"
    missing_path.write_text(
        source.replace(
            'exact = ["rtl/reset_sync.sv", "tb/tb_reset_sync.sv"]',
            'exact = ["rtl/missing_reset_sync.sv", "tb/tb_reset_sync.sv"]',
            1,
        ),
        encoding="utf-8",
    )
    missing_errors = profiles.repository_binding_errors(
        profiles.load_profiles(missing_path)
    )
    assert missing_errors == []
    check_plan = load_script("check_plan")
    missing_plan = check_plan.build_plan(
        ["rtl/reset_sync.sv"], profiles.load_profiles(missing_path)
    )
    assert missing_plan["commands"] == [
        "git diff --check -- rtl/reset_sync.sv",
        "make ci-fast",
    ]

    duplicate_path = tmp_path / "duplicate-owner.toml"
    duplicate_path.write_text(
        source
        + '\n[[owners]]\nexact = ["rtl/reset_sync.sv"]\n'
        + 'targets = ["test-reset-sync"]\n'
        + 'covers_profiles = ["decoder"]\n',
        encoding="utf-8",
    )
    duplicate_errors = profiles.repository_binding_errors(
        profiles.load_profiles(duplicate_path)
    )
    assert (
        "hardware source has multiple validation owners: rtl/reset_sync.sv"
        in duplicate_errors
    )


def test_validation_profile_rejects_stale_owner_target(tmp_path: Path) -> None:
    profiles = load_script("validation_profiles")
    source = profiles.DEFAULT_CONFIG_PATH.read_text(encoding="utf-8")
    invalid = source.replace(
        'targets = ["check-agent-workflow"]\n'
        'covers_profiles = ["workflow"]',
        'targets = ["missing-owner-target"]\n'
        'covers_profiles = ["workflow"]',
        1,
    )
    config_path = tmp_path / "validation_profiles.toml"
    config_path.write_text(invalid, encoding="utf-8")
    config = profiles.load_profiles(config_path)
    errors = profiles.repository_binding_errors(config)
    assert any("missing-owner-target" in error for error in errors)


def test_validation_profile_rejects_owner_rule_without_files(tmp_path: Path) -> None:
    profiles = load_script("validation_profiles")
    source = profiles.DEFAULT_CONFIG_PATH.read_text(encoding="utf-8")
    invalid = source.replace(
        'exact = ["tests/test_agent_workflow.py"]',
        'exact = ["tests/missing_agent_workflow.py"]',
        1,
    )
    config_path = tmp_path / "validation_profiles.toml"
    config_path.write_text(invalid, encoding="utf-8")
    config = profiles.load_profiles(config_path)
    errors = profiles.repository_binding_errors(config)
    assert any("owners[0] matches no repository path" in error for error in errors)


def test_ci_workflow_calls_only_the_canonical_local_gate() -> None:
    workflow_path = REPO_ROOT / ".github" / "workflows" / "ci.yml"
    workflow = yaml.load(workflow_path.read_text(encoding="utf-8"), Loader=yaml.BaseLoader)
    assert workflow["permissions"] == {"contents": "read"}
    steps = workflow["jobs"]["check"]["steps"]
    actions = [step["uses"] for step in steps if "uses" in step]
    assert "YosysHQ/setup-oss-cad-suite@v4" in actions
    verible_step = next(step for step in steps if step.get("name") == "Install pinned Verible")
    assert verible_step["env"]["VERIBLE_VERSION"] == "v0.0-4133-g873f559f"
    assert verible_step["env"]["VERIBLE_SHA256"] == (
        "73e83be9928e8274494ba39973ab07e76aed084c7da8bc81073b361ba196f9f4"
    )
    commands = [step["run"] for step in steps if "run" in step]
    assert "sha256sum -c -" in commands[0]
    assert commands[-2:] == [
        "uv sync --frozen",
        'PATH="$GITHUB_WORKSPACE/.venv/bin:$PATH" make check',
    ]


def test_required_toolchain_and_smoke_are_portable() -> None:
    combined = "\n".join(
        (REPO_ROOT / path).read_text(encoding="utf-8")
        for path in (
            "Makefile",
            "config/rtl_toolchain.lock",
            "scripts/check_tool_versions.py",
        )
    ).lower()
    for unused in ("boolector", "bitwuzla", "surfer"):
        assert unused not in combined
    smoke = (REPO_ROOT / "workflow-smoke" / "Makefile").read_text(encoding="utf-8")
    assert "/private/tmp" not in smoke
    assert "brew --prefix" not in smoke
    assert "LZ4_PREFIX to name an installed lz4 prefix" in smoke


def test_repository_skills_have_minimal_valid_frontmatter() -> None:
    for skill_path in sorted((REPO_ROOT / ".agents" / "skills").glob("*/SKILL.md")):
        text = skill_path.read_text(encoding="utf-8")
        assert text.startswith("---\n")
        _, frontmatter, body = text.split("---", maxsplit=2)
        metadata = yaml.safe_load(frontmatter)
        assert metadata["name"] == skill_path.parent.name
        assert isinstance(metadata.get("description"), str)
        assert metadata["description"].strip()
        assert body.strip().startswith("# ")


def test_validation_profile_config_rejects_unknown_coverage(tmp_path: Path) -> None:
    profiles = load_script("validation_profiles")
    source = profiles.DEFAULT_CONFIG_PATH.read_text(encoding="utf-8")
    invalid = source.replace('covers = []', 'covers = ["missing-profile"]', 1)
    config_path = tmp_path / "validation_profiles.toml"
    config_path.write_text(invalid, encoding="utf-8")
    with pytest.raises(profiles.ProfileConfigError, match="unknown profiles"):
        profiles.load_profiles(config_path)


def test_validation_profile_config_rejects_documented_command_drift(
    tmp_path: Path,
) -> None:
    profiles = load_script("validation_profiles")
    source = profiles.DEFAULT_CONFIG_PATH.read_text(encoding="utf-8")
    invalid = source.replace(
        'minimum_gate = "`make check-records`"',
        'minimum_gate = "`make stale-record-check`"',
        1,
    )
    config_path = tmp_path / "validation_profiles.toml"
    config_path.write_text(invalid, encoding="utf-8")
    with pytest.raises(profiles.ProfileConfigError, match="minimum_gate omits targets"):
        profiles.load_profiles(config_path)


def write_fake_make(path: Path) -> None:
    path.write_text(
        "#!/bin/sh\n"
        "printf '%s\\n' \"$*\" >> \"$FAKE_MAKE_CALLS\"\n"
        "printf '%s|%s|%s|%s\\n' \"${SBY_LOG_DIR-}\" \"${VERILATOR_LOG_DIR-}\" "
        "\"${RUN_QUIET_LOG_DIR-}\" \"${CHECK_SUMMARY_PATH-}\" >> \"$FAKE_MAKE_ENV\"\n"
        "if [ -n \"$FAKE_MAKE_FAIL_ON\" ] && [ \"$1\" = \"$FAKE_MAKE_FAIL_ON\" ]; then\n"
        "  echo 'ERROR: injected make failure'\n"
        "  exit 9\n"
        "fi\n"
        "echo 'verbose tool output retained in the run log'\n",
        encoding="utf-8",
    )
    path.chmod(0o755)


def run_validation(
    tmp_path: Path, *, fail_on: str = "", jobs: int = 1
) -> subprocess.CompletedProcess[str]:
    fake_make = tmp_path / "fake-make"
    write_fake_make(fake_make)
    environment = os.environ.copy()
    environment.update(
        {
            "FAKE_MAKE_CALLS": str(tmp_path / "make-calls.txt"),
            "FAKE_MAKE_ENV": str(tmp_path / "make-env.txt"),
            "FAKE_MAKE_FAIL_ON": fail_on,
        }
    )
    return subprocess.run(
        [
            sys.executable,
            str(REPO_ROOT / "scripts" / "run_validation.py"),
            "--run-id",
            "unit-run",
            "--run-root",
            str(tmp_path / "runs"),
            "--make",
            str(fake_make),
            "--jobs",
            str(jobs),
        ],
        cwd=REPO_ROOT,
        env=environment,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )


def test_validation_profile_runs_deduplicated_stages_and_writes_summary(
    tmp_path: Path,
) -> None:
    result = run_validation(tmp_path)
    assert result.returncode == 0
    calls = (tmp_path / "make-calls.txt").read_text(encoding="utf-8").splitlines()
    assert calls[0] == "check-agent-workflow"
    assert calls[1] == "workflow-smoke"
    assert calls[2] == "check"
    assert calls[3] == "-C workflow-smoke check-failures"
    assert calls[4].startswith("qor-report QOR_REPORT_DIR=")
    assert all(call != "qor" for call in calls)
    run_dir = tmp_path / "runs" / "unit-run"
    environments = (tmp_path / "make-env.txt").read_text(encoding="utf-8").splitlines()
    expected = "|".join(
        str(path)
        for path in (
            run_dir / "logs" / "sby",
            run_dir / "logs" / "verilator",
            run_dir / "logs" / "simulation",
            run_dir / "check-summary.json",
        )
    )
    assert environments == [expected, expected, expected, "|||", expected]
    metadata = json.loads((run_dir / "run.json").read_text(encoding="utf-8"))
    assert metadata["profile"] == "workflow"
    assert metadata["log_directory"] == str(run_dir / "logs")
    assert len(metadata["worktree_digest_sha256"]) == 64
    summary = json.loads((run_dir / "summary.json").read_text(encoding="utf-8"))
    assert summary["status"] == "PASS"
    assert summary["event_count"] == 5
    assert summary["duplicate_signatures"] == []
    assert "verbose tool output" not in result.stdout
    assert "verbose tool output" in (run_dir / "run.log").read_text(encoding="utf-8")


def test_validation_profile_stops_on_first_failure(tmp_path: Path) -> None:
    result = run_validation(tmp_path, fail_on="check")
    assert result.returncode == 9
    calls = (tmp_path / "make-calls.txt").read_text(encoding="utf-8").splitlines()
    assert calls == ["check-agent-workflow", "workflow-smoke", "check"]
    summary = json.loads(
        (tmp_path / "runs" / "unit-run" / "summary.json").read_text(
            encoding="utf-8"
        )
    )
    assert summary["status"] == "FAIL"
    assert "injected make failure" in result.stderr


def test_validation_profile_passes_bounded_parallelism_to_make(tmp_path: Path) -> None:
    result = run_validation(tmp_path, jobs=2)
    assert result.returncode == 0
    calls = (tmp_path / "make-calls.txt").read_text(encoding="utf-8").splitlines()
    assert calls[2] == "-j2 check"
    metadata = json.loads(
        (tmp_path / "runs" / "unit-run" / "run.json").read_text(encoding="utf-8")
    )
    assert metadata["make_jobs"] == 2


def test_validation_summary_keeps_not_run_visible_and_lists_slowest_leaf() -> None:
    events = load_script("validation_events")
    summary = events.summarize(
        [
            {
                "evidence_layer": "workflow",
                "name": "outer gate",
                "status": "PASS",
                "duration_seconds": 100.0,
                "signature": "stage:outer",
            },
            {
                "evidence_layer": "formal",
                "name": "proof",
                "status": "PASS",
                "duration_seconds": 4.5,
                "signature": "formal:proof-a",
            },
            {
                "evidence_layer": "physical",
                "name": "vivado",
                "status": "NOT_RUN",
                "signature": "vivado:run-a",
            },
        ],
        "summary-test",
    )
    assert summary["status"] == "NOT_RUN"
    assert [event["name"] for event in summary["slowest_leaf_events"]] == ["proof"]
    rendered = events.summary_text(summary)
    assert "4.500s formal proof" in rendered
    assert "100.000s" not in rendered


def test_qor_report_defaults_to_ignored_build_results() -> None:
    result = subprocess.run(
        ["make", "-n", "qor-report"],
        cwd=REPO_ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    assert result.returncode == 0
    assert "build/results/qor/latest.json" in result.stdout
    assert "reports/qor/latest.json" not in result.stdout


def test_obsolete_make_aliases_are_absent() -> None:
    makefile = (REPO_ROOT / "Makefile").read_text(encoding="utf-8")
    assert "\nformat-rtl:" not in makefile
    assert "\nverify-rtl:" not in makefile


def test_simulation_signature_tracks_compiled_variant(tmp_path: Path) -> None:
    run_quiet = load_script("run_quiet")
    executable = tmp_path / "Vdut"
    executable.write_text("placeholder\n", encoding="utf-8")
    metadata = executable.with_name(executable.name + ".validation.json")
    metadata.write_text(
        json.dumps({"compile_signature": "variant-a"}), encoding="utf-8"
    )
    assert run_quiet.executable_signature(str(executable)) == "variant-a"
    metadata.write_text(
        json.dumps({"compile_signature": "variant-b"}), encoding="utf-8"
    )
    assert run_quiet.executable_signature(str(executable)) == "variant-b"
