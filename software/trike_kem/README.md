# TRIKE KEM software bring-up

This directory contains the software-first TRIKE KEM integration used to
define and validate the later RTL boundaries.

The KEM control flow follows the AWS `bike-kem` structure:

- deterministic domain-separated SHAKE256 expansion;
- fixed-weight sampling;
- KeyGen, Encaps, and Decaps separation;
- recomputation of `H4` during Decaps;
- constant-time comparison and masked implicit rejection.

The decoder is a standalone port of the fixed-iteration, hardware-style
quantized Min-Sum arithmetic used by `myTRIKE-main` `ms_quant`. It executes
the complete configured iteration budget and reports the final residual
syndrome weight.

The current hash-domain encoding is a software bring-up convention because
the supplied TRIKE draft defines `H1`, `H2`, `H3`, `H4`, `K`, and `L` as
random oracles without an interoperability/KAT byte encoding. Replace the
domain constants and serialization only after the TRIKE byte-level
specification is frozen.

The secret-key structure stores derived `t0` and `r2` as an expanded-key
cache. The canonical TRIKE secret is still represented by
`sigma`, `sigma_prime`, and the three sparse parity-check supports.

Build and run:

```sh
make test-software-trike-kem
```

The default target checks the four submission profiles. For every profile it checks
a valid encapsulation and decapsulation, then corrupts `c2` and checks the
implicit-rejection path. A single deterministic case can be run with:

```sh
build/software/trike_kem/trike_kem_selftest trike160 1
```

This bring-up code is not a production side-channel implementation. Decaps
uses a fixed-iteration decoder, fixed-size arithmetic loops, constant-time
comparison, and masked secret selection. The polynomial extended-GCD used by
KeyGen still has data-dependent control flow and has not undergone leakage
analysis.

The build consumes the public-domain FIPS202 implementation carried by the
locally cloned Apache-2.0 AWS source at `build/upstream/aws-bike-kem`.
The pinned clone inspected during the port is commit
`f150a1c50105dabcb8be2ce9dca26c37937a5c13`.
