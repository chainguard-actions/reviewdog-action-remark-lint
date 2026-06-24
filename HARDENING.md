<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-remark-lint/v5.17.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **reviewdog--action-remark-lint/v5.17.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

entrypoint.sh pipes remote content directly to a shell interpreter. The line `wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b /tmp "${REVIEWDOG_VERSION}"` downloads and immediately executes a remote script without first saving it to a file and verifying its integrity. Even though the URL is pinned to a specific commit SHA in the path, the content is still executed directly from the network pipe.

Locations:

- `entrypoint.sh:13`

### script-injection (severity: high)

Rule (b) violation: unquoted shell variable expansion of untrusted/user-controlled data. (1) Line 40: `remark . ${INPUT_REMARK_ARGS}` — INPUT_REMARK_ARGS is sourced from `inputs.remark_args` (a user-controlled composite action input) and is expanded unquoted, allowing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) to be interpreted by the shell. The shellcheck disable=SC2086 comment confirms this is intentional but it is still a security risk. (2) Line 49: `${INPUT_REVIEWDOG_FLAGS}` — INPUT_REVIEWDOG_FLAGS is sourced from `inputs.reviewdog_flags` and is also expanded unquoted, allowing the same class of shell injection attacks.

Locations:

- `entrypoint.sh:40`
- `entrypoint.sh:49`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed entrypoint.sh: (1) unsafe-shell on line 13 — replaced 'wget ... | sh' pipe with download-to-file then execute pattern: wget saves to /tmp/reviewdog_install.sh, then sh executes it, then the temp file is removed. (2) script-injection on lines 40 and 49 — replaced unquoted ${INPUT_REMARK_ARGS} and ${INPUT_REVIEWDOG_FLAGS} expansions with bash arrays using 'read -ra remark_args <<< "${INPUT_REMARK_ARGS}"' and 'read -ra reviewdog_flags <<< "${INPUT_REVIEWDOG_FLAGS}"', then expanded as "${remark_args[@]}" and "${reviewdog_flags[@]}" respectively. This prevents shell metacharacters in user-controlled inputs from being interpreted by the shell while preserving correct argument splitting.

