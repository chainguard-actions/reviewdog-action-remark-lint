#!/bin/bash
set -eu # Increase bash error strictness

if [[ -n "${GITHUB_WORKSPACE}" ]]; then
  cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

export REVIEWDOG_VERSION=v0.21.0

echo "[action-remark-lint] Installing reviewdog..."
# Download install script to a temp file before executing (avoid pipe-to-sh)
_install_script="$(mktemp)"
wget -O "${_install_script}" -q https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh
sh "${_install_script}" -b /tmp "${REVIEWDOG_VERSION}"
rm -f "${_install_script}"

# Install remark and remark-lint if not yet present
if [[ "$(which remark)" == "" || "$(npm ls -g 2> /dev/null | grep remark-preset-lint-recommended)" == "" || "$(npm ls -g 2> /dev/null | grep remark-lint)" == "" ]]; then
  npm install -g remark-cli@10.0.0 remark-preset-lint-recommended@6.0.1 remark-lint@9.0.1
fi

echo "[action-remark-lint] Versions: $(remark --version), remark-lint: $(npm remark-lint --version)"

# Build remark args array from INPUT_REMARK_ARGS (safe word-splitting via read)
read -r -a remark_args <<< "${INPUT_REMARK_ARGS}"

# Build reviewdog flags array from INPUT_REVIEWDOG_FLAGS (safe word-splitting via read)
read -r -a reviewdog_flags <<< "${INPUT_REVIEWDOG_FLAGS}"

# Install plugins if package.sjon file is present
if [[ "${INPUT_INSTALL_DEPS}" == "true" && -f "package.json" ]]; then
  echo "[action-remark-lint] Installing npm dependencies..."
  npm install

  # Add default if `INPUT_REMARK_ARGS` is not set and no `remarkConfig` is found
  if ! grep -q '"remarkConfig"' package.json; then
    if [[ ${#remark_args[@]} -eq 0 ]]; then
      remark_args=(--use=remark-preset-lint-recommended)
    fi
  fi
fi

# Add default value if `INPUT_REMARK_ARGS` is not set and no `.remarkrc*` config file is found
if ! compgen -G .remarkrc* > /dev/null; then
  if [[ ${#remark_args[@]} -eq 0 ]]; then
    remark_args=(--use=remark-preset-lint-recommended)
  fi
fi

# NOTE: ${VAR,,} Is bash 4.0 syntax to make strings lowercase.
exit_val="0"
echo "[action-remark-lint] Checking markdown code with the remark-lint linter and reviewdog..."
remark . "${remark_args[@]}" 2>&1 |
  sed 's/\x1b\[[0-9;]*m//g' | # Removes ansi codes see https://github.com/reviewdog/errorformat/issues/51
  /tmp/reviewdog -f=remark-lint \
    -name="${INPUT_TOOL_NAME}" \
    -reporter="${INPUT_REPORTER}" \
    -filter-mode="${INPUT_FILTER_MODE}" \
    -fail-level="${INPUT_FAIL_LEVEL}" \
    -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
    -level="${INPUT_LEVEL}" \
    -tee \
    "${reviewdog_flags[@]}" || exit_val="$?"

echo "[action-remark-lint] Clean up reviewdog..."
rm /tmp/reviewdog

if [[ "${exit_val}" -ne '0' ]]; then
  exit 1
fi
