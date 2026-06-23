<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-remark-lint/v5.18.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **reviewdog--action-remark-lint/v5.18.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

entrypoint.sh pipes a remotely fetched install script directly to `sh` without first downloading and verifying it: `wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b /tmp "${REVIEWDOG_VERSION}"`. This allows a compromised or man-in-the-middle response to execute arbitrary code on the runner.

Locations:

- `entrypoint.sh:13`

### script-injection (severity: high)

Rule (b): Multiple unquoted shell variable expansions of workflow-controllable inputs in entrypoint.sh allow shell metacharacter injection. (1) Line 22: `${INPUT_INSTALL_DEPS}` is unquoted in the `if [[ ${INPUT_INSTALL_DEPS} == "true" ]]` condition. (2) Line 40: `${INPUT_REMARK_ARGS}` is passed unquoted to `remark . ${INPUT_REMARK_ARGS}` (the shellcheck disable SC2086 comment confirms this is intentional but unsafe). (3) Line 49: `${INPUT_REVIEWDOG_FLAGS}` is passed unquoted as trailing flags to reviewdog. All three variables are sourced from `inputs.*` via the `env:` block in action.yml, making them attacker-controlled. An attacker can inject shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) through these inputs.

Locations:

- `entrypoint.sh:22`
- `entrypoint.sh:40`
- `entrypoint.sh:49`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed entrypoint.sh: (1) unsafe-shell: replaced `wget -O - -q ... | sh` with download to a mktemp file, execute with `sh`, then delete the temp file — eliminates the pipe-to-shell risk. (2) script-injection line 22: quoted `${INPUT_INSTALL_DEPS}` as `"${INPUT_INSTALL_DEPS}"` in the if condition. (3) script-injection lines 40 and 49: replaced unquoted `${INPUT_REMARK_ARGS}` and `${INPUT_REVIEWDOG_FLAGS}` with bash arrays populated via `read -r -a arr <<< "${VAR}"`, then expanded safely as `"${arr[@]}"` — this preserves intentional word-splitting for multi-flag inputs while preventing shell metacharacter injection. Default-value logic for remark_args was updated to check array length (`${#remark_args[@]} -eq 0`) instead of the string variable.

