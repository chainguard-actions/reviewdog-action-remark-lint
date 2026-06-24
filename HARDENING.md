<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-remark-lint/v5.16.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **reviewdog--action-remark-lint/v5.16.2** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

entrypoint.sh pipes a remote install script directly to sh: `wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b /tmp "${REVIEWDOG_VERSION}"`. Even though the URL path contains a commit SHA, the script content is fetched and executed in a single pipeline without first downloading and verifying it separately.

Locations:

- `entrypoint.sh:13`

### script-injection (severity: high)

Rule (b): Unquoted shell variable expansions of workflow-controlled (untrusted) input-derived env vars in entrypoint.sh. (1) Line 22: `${INPUT_INSTALL_DEPS}` is unquoted inside `[[ ${INPUT_INSTALL_DEPS} == "true" ]]`. (2) Line 37: `${INPUT_REMARK_ARGS}` is passed unquoted to `remark . ${INPUT_REMARK_ARGS}` (the shellcheck disable=SC2086 comment acknowledges word-splitting but this allows shell metacharacter injection via the `remark_args` input). (3) Line 46: `${INPUT_REVIEWDOG_FLAGS}` is passed unquoted to the reviewdog command, allowing an attacker to inject arbitrary flags or shell metacharacters via the `reviewdog_flags` input.

Locations:

- `entrypoint.sh:22`
- `entrypoint.sh:37`
- `entrypoint.sh:46`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed entrypoint.sh: (1) unsafe-shell: Split the wget|sh pipe into download-to-tempfile then execute separately (mktemp + wget -O + sh + rm). (2) script-injection: Quoted ${INPUT_INSTALL_DEPS} in the [[ ]] test; used 'read -ra' to split INPUT_REMARK_ARGS and INPUT_REVIEWDOG_FLAGS into bash arrays, then expanded them as "${remark_args[@]}" and "${reviewdog_flags[@]}" respectively, preventing shell metacharacter injection while preserving multi-flag functionality. Executable bit (0755) preserved.

