# terraform-aws-ecr-docker-image threat model

## Overview

Reusable Terraform module creates an ECR repository and lifecycle policy, hashes local sources, and conditionally builds/pushes Docker images through local scripts (main.tf:5, push.tf:2).

| Component | Source |
| --- | --- |
| ECR repository/lifecycle | main.tf:5 |
| Hash and local-exec orchestration | push.tf:2 |
| Docker/ECR publication helper | push.sh:15 |

| Deployment or workflow | Resource or capability | Configuration and precedence | Safe effective value or location | Readers, writers, or recipients | Enforcing control | Evidence or unknowns |
| --- | --- | --- | --- | --- | --- | --- |
| default push | Published image | source_path + provider repository_url + tag(default latest) + platform(default linux/amd64) | ${repository_url}:${tag}; Docker build context exactly source_path | ECR and authorized image consumers | AWS CLI ECR token via password-stdin; registry IAM | push.tf:13; push.sh:15; variables.tf:11 |
| plan/apply | Build trigger | hash_script override else ${path.module}/hash.sh; source_path | MD5 over sorted selected file hashes; only hash triggers push | Terraform state and runner | Trusted script selection; local filesystem permissions | push.tf:2; hash.sh:18 |
| apply | Registry retention | image_name → repository → lifecycle policy | Repository var.image_name; tag-prefix images beyond 1 and any images beyond 2 eligible for expiry | ECR service and image consumers | ECR lifecycle rules | main.tf:5; main.tf:17 |

## Threat Model, Trust Boundaries, and Assumptions

Protected assets: Build host/Docker authority, AWS CLI credentials, confidentiality of source/build-context files and secrets, registry image integrity and retained rollback images (push.sh:23, main.tf:9). The source_path directory becomes the Docker build context; files copied by the Dockerfile can persist in image layers available to authorized ECR consumers (push.sh:23-27).

There are two AWS authority paths. Terraform’s provider creates the repository and policy; the local push script separately uses ambient AWS CLI credentials to obtain an ECR login password. It derives region from the repository URL, but does not copy or assume the provider identity. The caller must ensure both are authorized for the same intended target (main.tf:5, push.sh:20, push.sh:25).

Custom hash_script and push_script values override shipped helpers and are trusted executable configuration. The local-exec command also concatenates source_path, tag and platform without shell escaping and executes them through bash -c, so these ordinary scalar inputs must be trusted as executable configuration: shell syntax can execute before push.sh receives arguments. Dockerfiles and dependency/base-image sources also execute within the build environment. Do not accept these inputs or source content from unprivileged callers while retaining privileged runner/Docker credentials; this operator tool is not a sandbox (push.tf:3, push.tf:13-14, push.sh:23).

Source hashing provides a change trigger, not image authenticity. Only the returned source hash enters null_resource triggers; the tag/platform and push script are command arguments, not independent triggers. The default hash excludes Python cache files and root-dot paths, while Docker controls its own context semantics. Callers need a release policy that binds configuration and resulting artifacts, not merely this change detector (push.tf:8, hash.sh:18).

The example supplies only a hello-world image, local state and an AWS region. No production Fargate service, Cloudflare route or personal-data workload is established. Registry consumer policies, credential storage, Docker isolation, external helper behavior and actual image digests remain outside this repository. The architecture does not assert a vulnerability or imply that every custom-script caller is hostile (examples/python-hello-world/main.tf:10, examples/python-hello-world/src/main.py:9).

## Attack Surface, Mitigations, and Attacker Stories

These are prioritized hypotheses for review, not confirmed vulnerabilities. Each depends on the stated actor and deployment prerequisites.

| Priority | Scenario and capability gain | Prerequisites | Impact | Existing controls | Mitigation | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| P1 | Untrusted source, overridden scripts or shell syntax in source_path/tag/platform could execute with runner/Docker authority during planning or publishing. | Contributor-controlled content or scalar module inputs is accepted into a privileged Terraform/build workflow. | Runner compromise or unauthorized registry publication. | Execution remains operator-triggered; no public API accepts build jobs. | Review all shell-interpolated inputs as executable configuration; pass untrusted scalar values through a non-interpolated argument/environment boundary and isolate build credentials/host authority. | push.tf:3; push.tf:13; push.sh:23 |
| P2 | Provider and CLI identity mismatch could publish with an unintended principal or fail deployment. | Ambient CLI identity differs from Terraform provider configuration. | Incorrect publication attribution or deployment interruption. | Repository URL comes from Terraform; CLI login region comes from that URL; ECR IAM still applies. | Bind CLI/provider identity and verify target account/repository before publication. | main.tf:5; push.sh:20; push.sh:25 |
| P2 | A release may retain a previous image after tag/platform/script changes or hash-excluded Docker-context changes, including .dockerignore. | Caller changes only configuration or files omitted by hash.sh and expects a new build. | Artifact/deployment mismatch: a fresh Docker build can use different context while Terraform sees the same trigger. | Only the returned source hash triggers publication; root dot-paths and *.pyc are excluded, independently of Docker context semantics. | Bind release validation to effective Docker context, ignore rules, build configuration and actual published artifact; explicitly account for omitted inputs. | push.tf:8-14; hash.sh:18-25; push.sh:23; outputs.tf:6 |
| P3 | Lifecycle expiry could remove rollback inputs still needed by consumers. | More than configured retained images, or old images are relied upon outside module. | Build/rollback failure. | Explicit tag-prefix and overall image-count rules. | Set operational rollback retention expectations and preserve required digests elsewhere. | main.tf:17; main.tf:29 |
| P1 (conditional) | Sensitive build-context files are copied into image layers and published to ECR. | source_path contains confidential files, Docker context rules include them, and the Dockerfile copies them into the image; registry consumers lack authorization for those contents. | Secret/source disclosure to image readers and retained image copies. | Docker context inclusion and Dockerfile instructions govern what enters layers; ECR access control governs image readers, not source sensitivity. | Minimize the context, exclude sensitive files with reviewed .dockerignore rules, and use build secret mounts where supported instead of copying secrets into layers; inspect the resulting artifact before publication. | push.sh:23-27 |

## Severity Calibration (Critical, High, Medium, Low)

**Critical.** Critical needs verified compromise of exceptionally consequential build credentials or downstream systems, not merely the presence of local-exec. An operator intentionally running their own script already holds that authority.

**High.** High fits accepted untrusted build content gaining privileged runner execution or unauthorized publication consumed by important workloads. Consumer trust and runner/registry permissions determine reach.

**Medium.** Medium fits artifact mismatch, inability to publish due to credential mismatch, or lost rollback images with material operational consequences. A configuration change with no dependent deployment impact is weaker.

**Low.** Low fits localized build failure or harmless metadata mismatch. MD5 here is a change detector; claiming an authentication bypass requires a real consumer that treats it as authentication.

This is an offline, source-backed architecture review. No application execution, cloud state inspection or vulnerability validation was performed.

Repository: https://github.com/mathspace/terraform-aws-ecr-docker-image
Version: d0e325c003360c325be9bc867827669e216cfd32
