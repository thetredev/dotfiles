# Full PATH please
_expected_paths=(
    "/sbin"
    "/usr/sbin"
    "/usr/local/sbin"
    "${HOME}/.local/bin"
)

_actual_paths=($(echo "${PATH}" | tr ':' '\n'))

# Remove duplicates using AWK magic string
# See https://stackoverflow.com/a/11532197
_combined_paths=("${_actual_paths[@]}" "${_expected_paths[@]}")
_combined_paths=$(printf '%s\n' "${_combined_paths[@]}" | awk '!x[$0]++')

export PATH=$(echo -n "${_combined_paths}" | tr '\n' ':')
