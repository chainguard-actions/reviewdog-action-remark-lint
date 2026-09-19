<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-remark-lint/v5.20.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-remark-lint/v5.20.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

entrypoint.sh pipes a remotely-fetched install script directly to `sh` without first downloading and verifying it. The pattern `wget -O - -q https://...install.sh | sh -s -- ...` executes whatever the remote server returns, enabling supply-chain attacks if the URL is compromised or redirected. The script should be downloaded to a temporary file, its integrity verified (e.g. via checksum), and only then executed.

Locations:

- `entrypoint.sh:13`

### script-injection (severity: high)

Rule (b) violation: Multiple workflow-controllable input variables (set via `inputs.*` in action.yml's env: block) are expanded unquoted inside shell commands in entrypoint.sh, allowing shell metacharacter injection.

1. Line 22: `[[ ${INPUT_INSTALL_DEPS} == "true" ]]` — `$INPUT_INSTALL_DEPS` is unquoted; an attacker-controlled value containing shell metacharacters could break out of the test.

2. Line 40: `remark . ${INPUT_REMARK_ARGS}` — `$INPUT_REMARK_ARGS` is intentionally unquoted (shellcheck disabled) to allow word-splitting, but this also allows an attacker to inject arbitrary remark/shell arguments via the `remark_args` input.

3. Line 49: `${INPUT_REVIEWDOG_FLAGS}` — `$INPUT_REVIEWDOG_FLAGS` is unquoted at the end of the reviewdog invocation, allowing injection of arbitrary reviewdog flags or shell metacharacters via the `reviewdog_flags` input.

All three variables originate from `inputs.*` expressions mapped in action.yml and must be treated as untrusted. They should be double-quoted: `"${INPUT_INSTALL_DEPS}"`, `"${INPUT_REMARK_ARGS}"`, `"${INPUT_REVIEWDOG_FLAGS}"`.

Locations:

- `entrypoint.sh:22`
- `entrypoint.sh:40`
- `entrypoint.sh:49`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed entrypoint.sh:
1. unsafe-shell (line 13): Replaced `wget ... | sh -s -- -b /tmp VERSION` pipe with: download to a mktemp file, execute as `sh INSTALL_SCRIPT -b /tmp VERSION` (dropping '--' which was the shell's option terminator, not the script's), then remove the temp file.
2. script-injection (line 22): Quoted `${INPUT_INSTALL_DEPS}` → `"${INPUT_INSTALL_DEPS}"` in the [[ ]] conditional.
3. script-injection (line 40): Tokenized `INPUT_REMARK_ARGS` (list-style input) into a bash array via xargs/read-loop idiom; expanded as `"${remark_args[@]}"` in the remark invocation.
4. script-injection (line 49): Tokenized `INPUT_REVIEWDOG_FLAGS` (list-style input) into a bash array via xargs/read-loop idiom; expanded as `"${reviewdog_flags[@]}"` in the reviewdog invocation.

