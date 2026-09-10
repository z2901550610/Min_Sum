from __future__ import annotations

import importlib.util
import json
import os
import subprocess
import sys
from pathlib import Path

import pytest


REPO_ROOT = Path(__file__).resolve().parents[1]


@pytest.mark.parametrize("scope,expected", [
    ("representative", {"multiply": [12589, 106781], "inverse": [12589, 114043]}),
    ("all", {"multiply": [12589, 15581, 30389, 63773, 106781],
             "inverse": [12589, 15581, 35363, 69691, 114043]}),
])
def test_full_size_profile_selection(scope, expected, tmp_path: Path) -> None:
    result = subprocess.run(
        [sys.executable, str(REPO_ROOT / "scripts/run_trike_fold_profiles.py"),
         "--profiles", scope, "--list", "--build-dir", str(tmp_path / "unused")],
        capture_output=True, text=True, check=True,
    )
    assert json.loads(result.stdout) == expected
    assert not (tmp_path / "unused").exists()


@pytest.mark.parametrize("scope,trike,bike,reference", [
    ("representative", "trike160 trike512", "bike128 bike256", "TRIKE-2 TRIKE-9"),
    ("all", "trike160 trike256 trike384 trike512", "bike128 bike192 bike256",
     "TRIKE-2 TRIKE-5 TRIKE-7 TRIKE-9"),
])
def test_make_profile_defaults(scope, trike, bike, reference, tmp_path: Path) -> None:
    probe = tmp_path / "scope.mk"
    probe.write_text("print-scope:\n\t@echo '$(TRIKE_KEM_TEST_PROFILES)|$(TRIKE_MINSUM_PROFILES)|$(TRIKE_UNIFIED_KSIGN_PARAM_SETS)|$(BIKE_UNIFIED_RANDOM_PARAM_SETS)|$(TRIKE_REFERENCE_PARAM_SETS)'\n")
    result = subprocess.run(
        ["make", "--no-print-directory", "-s", f"VALIDATION_PROFILE_SET={scope}",
         "-f", "Makefile", "-f", str(probe),
         "print-scope"], cwd=REPO_ROOT, capture_output=True, text=True, check=True,
    )
    assert result.stdout.strip() == "|".join([trike, trike, trike, bike, reference])


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


def test_sby_quiet_pass_records_full_log_and_event(tmp_path: Path) -> None:
    result = run_wrapper(tmp_path, fail=False)
    assert result.returncode == 0
    assert "sby PASS: proof.sby prove" in result.stdout
    assert "engine output" not in result.stdout
    log_text = next((tmp_path / "logs").glob("*.log")).read_text(encoding="utf-8")
    assert "engine output that stays in the log" in log_text
    event = json.loads(
        (tmp_path / "results" / "events.jsonl").read_text(encoding="utf-8").strip()
    )
    assert event["task"] == "prove"
    assert event["tool"]["version"] == "fake-sby 1.0"
    assert event["source_digest"] and event["sources"] == ["proof.sby", "dut.sv"]
    assert event["evidence_layer"] == "formal"
    assert event["status"] == "PASS"
    assert event["run_id"] == "wrapper-test"
    assert "event_id" not in event


def test_sby_quiet_failure_preserves_return_code_and_diagnostics(tmp_path: Path) -> None:
    result = run_wrapper(tmp_path, fail=True)
    assert result.returncode == 1
    assert "sby FAIL: proof.sby prove" in result.stdout
    assert "ERROR: injected failure" in result.stderr
    event = json.loads((tmp_path / "results/events.jsonl").read_text().strip())
    assert event["status"] == "FAIL"


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
    assert "workflow" in profile_ids
    assert "formal" in profile_ids
    assert "check-agent-workflow" in plan["targets"]
    assert "make check" not in plan["commands"]
    assert "formal-ct-control" in plan["targets"]
    assert "make formal-fast" not in plan["commands"]
    assert "release_commands" not in plan
    assert plan["read_only"] is True


def test_check_plan_self_routes_workflow_and_scopes_hardware_tokens() -> None:
    check_plan = load_script("check_plan")
    config_plan = check_plan.build_plan(["config/validation_profiles.toml"])
    assert [profile["id"] for profile in config_plan["profiles"]] == [
        "workflow",
    ]
    assert config_plan["commands"] == [
        "git diff --check -- config/validation_profiles.toml",
        "make check-agent-workflow",
    ]

    test_plan = check_plan.build_plan(["tests/test_agent_workflow.py"])
    assert [profile["id"] for profile in test_plan["profiles"]] == ["workflow"]
    assert test_plan["commands"] == [
        "git diff --check -- tests/test_agent_workflow.py",
        "make check-agent-workflow",
    ]
    assert "release_commands" not in test_plan

    documentation_plan = check_plan.build_plan(
        ["docs/k_sign_notes.md", "docs/parameter_notes.md"]
    )
    assert [profile["id"] for profile in documentation_plan["profiles"]] == ["records"]
    assert documentation_plan["commands"] == [
        "git diff --check -- docs/k_sign_notes.md docs/parameter_notes.md",
    ]

    dependency_plan = check_plan.build_plan(["pyproject.toml"])
    assert dependency_plan["commands"] == [
        "git diff --check -- pyproject.toml",
        "make python-sync check-agent-workflow",
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
    assert "make test-reset-sync" in scoped.stdout


def test_check_plan_uses_owning_targets_before_aggregate_gates() -> None:
    check_plan = load_script("check_plan")

    formal_plan = check_plan.build_plan(["formal/tile_scheduler_formal.sv"])
    assert [profile["id"] for profile in formal_plan["profiles"]] == ["formal"]
    assert formal_plan["commands"] == [
        "git diff --check -- formal/tile_scheduler_formal.sv",
        "make formal-tile-scheduler",
    ]
    assert "release_commands" not in formal_plan

    ram_plan = check_plan.build_plan(["rtl/ram_i.sv"])
    assert [profile["id"] for profile in ram_plan["profiles"]] == [
        "local_rtl",
        "decoder",
    ]
    assert ram_plan["commands"] == [
        "git diff --check -- rtl/ram_i.sv",
        "make test-ram-i",
    ]
    assert "release_commands" not in ram_plan

    kem_plan = check_plan.build_plan(["rtl/kem_ct_compare_select.sv"])
    assert kem_plan["commands"] == [
        "git diff --check -- rtl/kem_ct_compare_select.sv",
        "make test-kem-ct-compare-select formal-ct-select",
    ]
    assert "release_commands" not in kem_plan


def test_check_plan_command_coverage_links_to_workflow() -> None:
    check_plan = load_script("check_plan")
    plan = check_plan.build_plan(
        [
            "scripts/run_validation.py",
            "rtl/decoder_top.sv",
            "formal/tile_scheduler.sby",
        ]
    )
    assert set(plan["targets"]) == {
        "validate-workflow", "test-integration", "formal-tile-scheduler"
    }
    assert plan["guidance"] == "docs/workflow.md"
    assert "manual_requirements" not in plan


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


def test_verilator_tests_use_target_scoped_build_directories() -> None:
    catalog = load_script("test_catalog")
    makefile = catalog.render_make(catalog.load_catalog())
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
        "make test-trike-encaps-uv-core test-trike-encaps-uv-core-external-store",
    ]
    assert "release_commands" not in implementation_plan

    runtime_tb_plan = check_plan.build_plan(
        ["tb/tb_trike_pseudohash512_runtime.sv"]
    )
    assert runtime_tb_plan["commands"] == [
        "git diff --check -- tb/tb_trike_pseudohash512_runtime.sv",
        "make test-trike-pseudohash-runtime",
    ]
    assert "make test-kem-unit" not in runtime_tb_plan["commands"]

    reference_plan = check_plan.build_plan(
        ["tb/tb_trike_keygen_secret_sampler_schedule.sv"]
    )
    assert reference_plan["commands"] == [
        "git diff --check -- tb/tb_trike_keygen_secret_sampler_schedule.sv",
        "make test-trike-keygen-secret-schedule-reference",
    ]
    assert "make ci-kem-reference" not in reference_plan["commands"]


def test_each_named_test_target_has_at_most_one_verilator_compile() -> None:
    catalog = load_script("test_catalog")
    makefile = catalog.render_make(catalog.load_catalog())
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


def test_validation_profiles_drive_routing() -> None:
    profiles = load_script("validation_profiles")
    config = profiles.load_profiles()
    selected, owners = profiles.classify_paths(
        ["docs/removed-record.md", "formal/trike_ct_verify_stream_formal.sv"],
        config,
    )
    assert selected == ["records", "formal"]
    assert [action.targets for action in owners] == [("formal-ct-control",)]
    assert [action.covers_profiles for action in owners] == [("formal",)]



def test_validation_profile_repository_bindings_are_live() -> None:
    profiles = load_script("validation_profiles")
    config = profiles.load_profiles()
    assert profiles.repository_binding_errors(config) == []


def test_public_parameter_and_kem_aggregate_plans_do_not_repeat_static_gate() -> None:
    check_plan = load_script("check_plan")
    decoder_plan = check_plan.build_plan(["rtl/decoder_profile_config.sv"])
    assert decoder_plan["commands"] == [
        "git diff --check -- rtl/decoder_profile_config.sv",
        "make test-integration",
    ]
    assert "public_params" in [profile["id"] for profile in decoder_plan["profiles"]]

    trike_plan = check_plan.build_plan(["rtl/trike_decaps_profile_config.sv"])
    assert trike_plan["commands"] == [
        "git diff --check -- rtl/trike_decaps_profile_config.sv",
        "make test-trike-decaps-runtime-profiles-reference",
    ]
    assert all(command != "make check-fast" for command in trike_plan["commands"])

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
        profiles.CATALOG_PATH.read_text().replace(
            'exact = ["rtl/reset_sync.sv", "tb/tb_reset_sync.sv"]',
            'exact = ["rtl/missing_reset_sync.sv", "tb/tb_reset_sync.sv"]',
            1,
        ),
        encoding="utf-8",
    )
    missing_errors = profiles.repository_binding_errors(
        profiles.load_profiles(catalog_path=missing_path)
    )
    assert missing_errors == []
    check_plan = load_script("check_plan")
    missing_plan = check_plan.build_plan(
        ["rtl/reset_sync.sv"], profiles.load_profiles(catalog_path=missing_path)
    )
    assert missing_plan["commands"] == [
        "git diff --check -- rtl/reset_sync.sv",
        "make test-integration",
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
    assert any("matches no repository path" in error for error in errors)


def test_validation_profile_config_rejects_unknown_coverage(tmp_path: Path) -> None:
    profiles = load_script("validation_profiles")
    source = profiles.DEFAULT_CONFIG_PATH.read_text(encoding="utf-8")
    invalid = source.replace('covers = []', 'covers = ["missing-profile"]', 1)
    config_path = tmp_path / "validation_profiles.toml"
    config_path.write_text(invalid, encoding="utf-8")
    with pytest.raises(profiles.ProfileConfigError, match="unknown profiles"):
        profiles.load_profiles(config_path)


def write_fake_make(path: Path) -> None:
    path.write_text(
        "#!/bin/sh\n"
        "printf '%s\\n' \"$*\" >> \"$FAKE_MAKE_CALLS\"\n"
        "printf '%s|%s|%s|%s\\n' \"${SBY_LOG_DIR-}\" \"${VERILATOR_LOG_DIR-}\" "
        "\"${RUN_QUIET_LOG_DIR-}\" \"${VALIDATION_EVENTS_PATH-}\" >> \"$FAKE_MAKE_ENV\"\n"
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
    assert calls[2] == "-C workflow-smoke check-failures"
    assert len(calls) == 3
    assert not any("qor" in call or call == "check" for call in calls)
    run_dir = tmp_path / "runs" / "unit-run"
    environments = (tmp_path / "make-env.txt").read_text(encoding="utf-8").splitlines()
    expected = "|".join(
        str(path)
        for path in (
            run_dir / "logs" / "sby",
            run_dir / "logs" / "verilator",
            run_dir / "logs" / "simulation",
            run_dir / "events.jsonl",
        )
    )
    assert environments == [expected, expected, "|||"]
    metadata = json.loads((run_dir / "run.json").read_text(encoding="utf-8"))
    assert metadata["profile"] == "workflow"
    assert metadata["log_directory"] == str(run_dir / "logs")
    assert len(metadata["worktree_digest_sha256"]) == 64
    summary = json.loads((run_dir / "summary.json").read_text(encoding="utf-8"))
    assert summary["status"] == "PASS"
    assert summary["event_count"] == 3
    assert summary["duplicate_signatures"] == []
    assert "verbose tool output" not in result.stdout
    assert "verbose tool output" in (run_dir / "run.log").read_text(encoding="utf-8")


def test_validation_profile_stops_on_first_failure(tmp_path: Path) -> None:
    result = run_validation(tmp_path, fail_on="workflow-smoke")
    assert result.returncode == 9
    calls = (tmp_path / "make-calls.txt").read_text(encoding="utf-8").splitlines()
    assert calls == ["check-agent-workflow", "workflow-smoke"]
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
    assert calls[1] == "-j2 workflow-smoke"
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


@pytest.mark.parametrize("path", ["scripts/scratch_analysis.py", "experiments/sweep.csv"])
def test_research_files_need_no_registration(path, monkeypatch):
    profiles = load_script("validation_profiles")
    paths = profiles.repository_paths()
    monkeypatch.setattr(profiles, "repository_paths", lambda root: paths + [path])
    assert profiles.repository_binding_errors(profiles.load_profiles()) == []
    plan = load_script("check_plan").build_plan([path])
    assert plan["unrouted_paths"] == [path]
    assert plan["targets"] == []


def test_daily_gate_excludes_formal_synthesis_and_workflow():
    result = subprocess.run(["make", "-n", "ci-fast"], cwd=REPO_ROOT,
                            text=True, capture_output=True, check=True)
    for heavy in [".sby", "synth_xilinx", "check_tool_versions.py", "check_project_records.py", "run_validation.py"]:
        assert heavy not in result.stdout
    assert "--binary" in result.stdout


def test_helper_and_skill_changes_do_not_qualify_toolchain():
    planner = load_script("check_plan")
    assert planner.build_plan(["scripts/sby_quiet.py"])["targets"] == ["check-agent-workflow"]
    assert planner.build_plan(["docs/design/coding.md"])["targets"] == []
    assert planner.build_plan(["Makefile"])["targets"] == ["check-agent-workflow"]


@pytest.mark.parametrize("strict,returncode,output,failed", [
    (False, 0, "tool 2.0", False), (True, 0, "tool 2.0", True),
    (False, 0, "tool 1.0", False), (True, 0, "tool 1.0", False),
    (False, 1, "tool 1.0", True), (False, None, "", True),
])
def test_tool_version_policy(monkeypatch, capsys, strict, returncode, output, failed):
    versions = load_script("check_tool_versions")
    monkeypatch.setattr(versions, "load_lock", lambda: {"verilator": "tool 1.0"})
    monkeypatch.setattr(sys, "argv", ["check_tool_versions.py"] + (["--check"] if strict else []))
    def run(*args, **kwargs):
        if returncode is None:
            raise FileNotFoundError("missing tool")
        return subprocess.CompletedProcess(args, returncode, output, "")
    monkeypatch.setattr(versions.subprocess, "run", run)
    if failed:
        with pytest.raises(SystemExit):
            versions.main()
    else:
        versions.main()
        assert ("WARNING" if output == "tool 2.0" else "PASS") in capsys.readouterr().out


def test_toy_fixture_preserves_timestamp_only_when_content_matches(tmp_path):
    generator = load_script("gen_toy_case_fixture")
    path = tmp_path / "toy.svh"
    generator.emit_fixture(path, error_positions=[14])
    original = path.read_bytes()
    os.utime(path, ns=(1_000_000_000, 1_000_000_000))
    generator.emit_fixture(path, error_positions=[14])
    assert path.stat().st_mtime_ns == 1_000_000_000
    generator.emit_fixture(path, error_positions=[13])
    assert path.read_bytes() != original
    generator.emit_fixture(path, error_positions=[14])
    assert path.read_bytes() == original


def test_failure_output_is_bounded_without_losing_log_or_exit_code(tmp_path):
    environment = os.environ.copy()
    environment.update(VALIDATION_RUN_ID="bounded-output-test",
                       RUN_QUIET_LOG_DIR=str(tmp_path / "logs"),
                       VALIDATION_EVENTS_PATH=str(tmp_path / "events.jsonl"),
                       RUN_QUIET_MAX_LINES="20")
    result = subprocess.run(
        [sys.executable, str(REPO_ROOT / "scripts/run_quiet.py"), sys.executable,
         "-c", "for i in range(100): print(f'error: diagnostic {i}')\nraise SystemExit(7)"],
        env=environment, text=True, capture_output=True,
    )
    assert result.returncode == 7
    assert len(result.stderr.splitlines()) <= 41
    assert "diagnostic 0" in result.stderr and "diagnostic 99" in result.stderr
    log = next((tmp_path / "logs").glob("*.log")).read_text()
    assert len(log.splitlines()) == 100
    assert json.loads((tmp_path / "events.jsonl").read_text())["status"] == "FAIL"


def test_verilator_diagnostics_are_bounded_and_deduplicated(capsys, tmp_path):
    wrapper = load_script("verilator_quiet")
    wrapper.emit_filtered("\n".join(f"%Error: diagnostic {i}" for i in range(100)),
                          failed=True, log_file=tmp_path / "full.log")
    lines = capsys.readouterr().err.splitlines()
    assert len(lines) <= 41
    assert len(lines) == len(set(lines))
    assert "%Error: diagnostic 0" in lines and "%Error: diagnostic 99" in lines


def test_docs_and_lessons_are_light_but_physical_records_are_checked():
    planner = load_script("check_plan")
    assert planner.build_plan(["README.md", "docs/workflow.md"])["targets"] == []
    assert planner.build_plan(["docs/experiments.md"])["targets"] == []
    assert planner.build_plan(["docs/design/vivado_baseline_registry.md"])["targets"] == ["check-records"]


@pytest.mark.parametrize("path,expected", [
    ("Makefile", ["check-agent-workflow"]),
    ("rtl/ram_accum.sv", ["test-ram-accum"]),
    ("docs/design/implementation_status.md", []),
    ("rtl/decoder_profile_config.sv", ["test-integration"]),
])
def test_focused_plan_has_one_check_set(path, expected):
    plan = load_script("check_plan").build_plan([path])
    assert plan["targets"] == expected
    assert not any("release" in key or "iteration" in key for key in plan)


def test_reference_and_qor_do_not_require_unrelated_qualification():
    records = load_script("check_project_records")
    dependencies, _ = records.parse_make_targets((REPO_ROOT / "Makefile").read_text())
    for target in ["ci-kem-reference", "qor", "qor-record"]:
        closure = records.dependency_closure(target, dependencies)
        assert not closure.intersection({"check-local-tools", "check-tool-versions", "check-records", "check-rtl"})
    result = subprocess.run(["make", "-n", "qor"], cwd=REPO_ROOT,
                            capture_output=True, text=True, check=True)
    assert "QOR_LINT_STATUS=NOT_RUN" in result.stdout
    assert "formal/kem_ct_compare_select.sby" in result.stdout


@pytest.mark.parametrize("paths", [
    ["rtl/ram_i.sv", "rtl/k_sign_overlap_scheduler.sv"],
    ["rtl/ram_i.sv", "rtl/unowned_decoder_probe.sv"],
    ["rtl/ram_i.sv", "rtl/k_sign_overlap_scheduler.sv", "scripts/run_validation.py"],
])
def test_combined_plan_preserves_each_files_checks(paths):
    planner = load_script("check_plan")
    expected = {target for path in paths for target in planner.build_plan([path])["targets"]}
    forward = planner.build_plan(paths)["targets"]
    backward = planner.build_plan(list(reversed(paths)))["targets"]
    assert set(forward) == set(backward) == expected
    assert len(forward) == len(set(forward))


@pytest.mark.parametrize("legacy_id", [None, "EXP-0084", "bad-id"])
def test_vivado_manifest_does_not_require_an_experiment(legacy_id, tmp_path):
    records = load_script("check_project_records")
    source = next((REPO_ROOT / "reports/vivado/manifests").glob("RUN-*.toml"))
    lines = [line for line in source.read_text().splitlines()
             if not line.startswith("experiment_id =")]
    if legacy_id is not None:
        lines.insert(0, f'experiment_id = "{legacy_id}"')
    path = tmp_path / source.name
    path.write_text("\n".join(lines) + "\n")
    if legacy_id == "bad-id":
        with pytest.raises(SystemExit, match="invalid legacy experiment_id"):
            records.validate_manifest(path, set())
    else:
        records.validate_manifest(path, set())


def test_standalone_formal_keeps_independent_events(tmp_path, monkeypatch):
    wrapper = load_script("sby_quiet")
    fake_sby = tmp_path / "fake-sby"
    write_fake_sby(fake_sby)
    (tmp_path / "dut.sv").write_text("module dut; endmodule\n")
    (tmp_path / "proof.sby").write_text("[files]\ndut.sv\n")
    monkeypatch.chdir(tmp_path)
    monkeypatch.setenv("REAL_SBY", str(fake_sby))
    monkeypatch.setenv("SBY_LOG_DIR", str(tmp_path / "logs"))
    monkeypatch.setenv("VALIDATION_RUN_ROOT", str(tmp_path / "runs"))
    monkeypatch.delenv("VALIDATION_EVENTS_PATH", raising=False)
    monkeypatch.delenv("FAKE_SBY_FAIL", raising=False)
    monkeypatch.setattr(sys, "argv", ["sby_quiet.py", "proof.sby", "prove"])
    for _ in range(2):
        monkeypatch.delenv("VALIDATION_RUN_ID", raising=False)
        assert wrapper.main() == 0
    paths = list((tmp_path / "runs").glob("*/events.jsonl"))
    assert len(paths) == 2
    for path in paths:
        event = json.loads(path.read_text())
        assert event["status"] == "PASS" and event["task"] == "prove"
        assert event["sources"] == ["proof.sby", "dut.sv"]
        assert Path(event["log"]).is_file()
