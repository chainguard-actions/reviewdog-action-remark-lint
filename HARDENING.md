<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-remark-lint/v5.19.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-remark-lint/v5.19.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

entrypoint.sh downloads a remote install script and pipes it directly to `sh` without first saving it to disk for inspection. This allows a compromised or MITM'd remote server to execute arbitrary code on the runner. Offending line: `wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh | sh -s -- -b /tmp "${REVIEWDOG_VERSION}"`

Locations:

- `entrypoint.sh:13`

### script-injection (severity: high)

Sub-rule (b): Multiple unquoted shell variable expansions of workflow-controllable inputs in entrypoint.sh. These variables are populated from `inputs.*` values (set via env: in action.yml) and are therefore attacker-controlled. Unquoted expansions allow shell metacharacter injection (word splitting, glob expansion, command substitution via `;`, `|`, `&`, `$(...)`, etc.).

1. Line 23: `if [[ ${INPUT_INSTALL_DEPS} == "true" ...` — `$INPUT_INSTALL_DEPS` is unquoted inside `[[ ]]`.
2. Line 40: `remark . ${INPUT_REMARK_ARGS} 2>&1 |` — `$INPUT_REMARK_ARGS` is unquoted (a `# shellcheck disable=SC2086` comment even acknowledges the word-splitting). An attacker can inject arbitrary remark/shell arguments.
3. Line 50: `    ${INPUT_REVIEWDOG_FLAGS} || exit_val="$?"` — `$INPUT_REVIEWDOG_FLAGS` is unquoted, allowing injection of arbitrary reviewdog flags or shell metacharacters.

Locations:

- `entrypoint.sh:23`
- `entrypoint.sh:40`
- `entrypoint.sh:50`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed entrypoint.sh:
1. unsafe-shell: Replaced `wget ... | sh -s -- -b /tmp "${REVIEWDOG_VERSION}"` with downloading the install script to a mktemp temp file, then executing `sh "${INSTALL_SCRIPT}" -b /tmp "${REVIEWDOG_VERSION}"` (dropped the '--' which was the shell's option terminator, not the script's), then removing the temp file.
2. script-injection line 23: Added quotes around ${INPUT_INSTALL_DEPS} in the [[ ]] conditional test.
3. script-injection lines 40 and 50: INPUT_REMARK_ARGS and INPUT_REVIEWDOG_FLAGS are list-style inputs; replaced unquoted expansions with xargs-based array tokenization (quote-aware, handles spaces and quoted substrings). Arrays are expanded as "${remark_args[@]}" and "${reviewdog_flags[@]}" respectively. The script's #!/bin/bash shebang ensures bash arrays are available.

