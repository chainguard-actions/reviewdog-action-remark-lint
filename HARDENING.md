<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-remark-lint/v5.17.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-remark-lint/v5.17.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

entrypoint.sh pipes a remote install script directly to `sh` without first downloading and verifying it: `wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh | sh -s -- -b /tmp "${REVIEWDOG_VERSION}"`. Although the URL is pinned to a specific commit SHA, the content is still executed immediately from the network without any integrity check on the local runner side. The script should be downloaded to a file first, verified, and then executed separately.

Locations:

- `entrypoint.sh:13`

### script-injection (severity: high)

Rule (b) violation: Two unquoted shell variable expansions of workflow-controllable inputs allow shell metacharacter injection. (1) `remark . ${INPUT_REMARK_ARGS}` on line 40 — INPUT_REMARK_ARGS is sourced from `inputs.remark_args` and expanded unquoted, allowing word-splitting and glob expansion of attacker-controlled content. A `# shellcheck disable=SC2086` comment acknowledges this but does not mitigate the injection risk. (2) `${INPUT_REVIEWDOG_FLAGS}` on line 50 — INPUT_REVIEWDOG_FLAGS is sourced from `inputs.reviewdog_flags` and expanded unquoted in the reviewdog invocation, similarly allowing injection of shell metacharacters. Both variables should be quoted or handled via an array to prevent injection.

Locations:

- `entrypoint.sh:40`
- `entrypoint.sh:50`

### missing-permissions (severity: medium)

None of the four workflow files define a `permissions:` key at the top level or at the job level. Without explicit permissions, workflows run with the default token permissions (which may include write access to contents, pull-requests, etc.), violating the principle of least privilege. Each workflow should declare minimal required permissions explicitly.

Locations:

- `.github/workflows/depup.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/reviewdog.yml:1`
- `.github/workflows/test.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection, missing-permissions

**Notes:**

1. unsafe-shell (entrypoint.sh:13): Replaced `wget ... | sh` pipe with a two-step approach: download to /tmp/reviewdog-install.sh, execute with `sh`, then remove the temp file. 2. script-injection (entrypoint.sh:40,50): Replaced unquoted `${INPUT_REMARK_ARGS}` and `${INPUT_REVIEWDOG_FLAGS}` with bash arrays built via `IFS=' ' read -r -a`, then expanded as `"${remark_args[@]}"` and `"${reviewdog_flags[@]}"` to prevent word-splitting and glob injection. Removed the `# shellcheck disable=SC2086` comment that was suppressing the warning. 3. missing-permissions: Added top-level `permissions:` blocks to all four workflow files — depup.yml (contents:write, pull-requests:write), release.yml (contents:write, pull-requests:write), reviewdog.yml (contents:read, checks:write, pull-requests:write), test.yml (contents:read, checks:write, pull-requests:write).

