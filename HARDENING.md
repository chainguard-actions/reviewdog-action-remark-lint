<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-remark-lint/v5.16.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-remark-lint/v5.16.2** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

entrypoint.sh line 13 downloads a remote install script and pipes it directly to `sh` for execution: `wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b /tmp "${REVIEWDOG_VERSION}"`. Even though the URL is pinned to a specific commit SHA in the path, piping remote content directly to a shell interpreter is an unsafe pattern — if the remote content is ever tampered with or the URL is redirected, arbitrary code executes immediately.

Locations:

- `entrypoint.sh:13`

### script-injection (severity: high)

Rule (b) violation: entrypoint.sh uses unquoted shell variable expansions of env vars that hold workflow-controllable input values. (1) Line 40: `remark . ${INPUT_REMARK_ARGS} 2>&1 |` — INPUT_REMARK_ARGS is sourced from `inputs.remark_args` and is expanded unquoted, allowing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) to be injected by a caller. (2) Line 49: `${INPUT_REVIEWDOG_FLAGS} || exit_val="$?"` — INPUT_REVIEWDOG_FLAGS is sourced from `inputs.reviewdog_flags` and is also expanded unquoted. Both variables should be double-quoted: `"${INPUT_REMARK_ARGS}"` and `"${INPUT_REVIEWDOG_FLAGS}"`.

Locations:

- `entrypoint.sh:40`
- `entrypoint.sh:49`

### missing-permissions (severity: medium)

None of the 4 workflow files define a `permissions:` key at the top level or at the job level. Without explicit permissions, workflows run with the repository's default token permissions, which may be overly broad (e.g., write access to contents, pull-requests, etc.). Each workflow should declare minimal required permissions.

Locations:

- `.github/workflows/depup.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/reviewdog.yml:1`
- `.github/workflows/test.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection, missing-permissions

**Notes:**

1. unsafe-shell (entrypoint.sh line 13): Replaced `wget ... | sh` pipe pattern with a two-step approach: download the install script to /tmp/reviewdog-install.sh, execute it with `sh`, then remove it. 2. script-injection (entrypoint.sh lines 40 and 49): Added double-quotes around ${INPUT_REMARK_ARGS} and ${INPUT_REVIEWDOG_FLAGS} to prevent shell metacharacter injection; removed the now-unnecessary shellcheck disable comment. 3. missing-permissions: Added top-level `permissions:` blocks to all 4 workflow files — depup.yml (contents:write, pull-requests:write), release.yml (contents:write, pull-requests:write), reviewdog.yml (contents:read, checks:write, pull-requests:write), test.yml (contents:read, checks:write, pull-requests:write).

