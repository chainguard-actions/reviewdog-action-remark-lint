<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-remark-lint/v5.18.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-remark-lint/v5.18.0** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

entrypoint.sh pipes the output of wget directly to `sh` for execution: `wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b /tmp "${REVIEWDOG_VERSION}"`. This executes remotely-fetched content without first saving and verifying it, allowing a compromised or MITM'd script to run arbitrary commands on the runner.

Locations:

- `entrypoint.sh:13`

### script-injection (severity: high)

Sub-rule (b): `${INPUT_REMARK_ARGS}` is expanded unquoted in the shell command `remark . ${INPUT_REMARK_ARGS} 2>&1 |`. This variable is populated from `inputs.remark_args` (a caller-controlled value) via the env block in action.yml. An attacker-supplied value containing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) will be word-split and interpreted by bash, enabling command injection. The shellcheck disable comment (SC2086) on the preceding line acknowledges but does not fix this issue.

Locations:

- `entrypoint.sh:38`

### script-injection (severity: high)

Sub-rule (b): `${INPUT_REVIEWDOG_FLAGS}` is expanded unquoted in the reviewdog invocation: `${INPUT_REVIEWDOG_FLAGS} || exit_val="$?"`. This variable is populated from `inputs.reviewdog_flags` (a caller-controlled value) via the env block in action.yml. An attacker-supplied value containing shell metacharacters will be word-split and interpreted by bash, enabling command injection.

Locations:

- `entrypoint.sh:47`

### missing-permissions (severity: medium)

None of the workflow files define a top-level `permissions:` key, and no job in any workflow defines job-level permissions. Without explicit permissions, workflows run with the default (potentially write) token permissions, violating the principle of least privilege. Affected files: depup.yml, release.yml, reviewdog.yml, test.yml.

Locations:

- `.github/workflows/depup.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/reviewdog.yml:1`
- `.github/workflows/test.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection, missing-permissions

**Notes:**

Fixed 4 findings in entrypoint.sh and 4 workflow files:

1. unsafe-shell (entrypoint.sh:13): Replaced `wget ... | sh` pipe with safe download-then-execute pattern using mktemp.

2. script-injection (entrypoint.sh:38): Replaced unquoted `${INPUT_REMARK_ARGS}` with a bash array using `read -ra REMARK_ARGS_ARRAY <<< "${INPUT_REMARK_ARGS}"` and `"${REMARK_ARGS_ARRAY[@]}"` expansion.

3. script-injection (entrypoint.sh:47): Replaced unquoted `${INPUT_REVIEWDOG_FLAGS}` with a bash array using `read -ra REVIEWDOG_FLAGS_ARRAY <<< "${INPUT_REVIEWDOG_FLAGS}"` and `"${REVIEWDOG_FLAGS_ARRAY[@]}"` expansion.

4. missing-permissions: Added top-level `permissions:` blocks to depup.yml (contents:write, pull-requests:write), release.yml (contents:write, pull-requests:write), reviewdog.yml (contents:read, checks:write, pull-requests:write), and test.yml (contents:read, checks:write, pull-requests:write).

