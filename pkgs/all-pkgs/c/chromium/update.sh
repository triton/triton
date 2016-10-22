#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o functrace
set -o pipefail

# Setup the temporary storage area
export TMPDIR=""
cleanup() {
  CODE="$?"
  echo "Cleaning up..." >&2
  if [ -n "$TMPDIR" ]; then
    rm -rf "$TMPDIR"
  fi
  exit "$?"
}
trap cleanup EXIT ERR INT QUIT PIPE TERM
export TMPDIR="$(mktemp -d /tmp/chromium-updater.XXXXXXXXXX)"

# Find the top git level
TOP_LEVEL="$(pwd)"
while ! [ -d "${TOP_LEVEL}/.git" ]; do
  TOP_LEVEL="$(readlink -f "${TOP_LEVEL}/..")"
done

# Build all of the packages needed to run this script
echo "Building script dependencies..." >&2
declare -r exp="let pkgs = import ./. { };
in pkgs.buildEnv {
  name = \"chromium-updater\";
  paths = with pkgs; [
    coreutils
    curl
    gawk
    jq
    openssl
  ];
}"
pushd "$TOP_LEVEL" >/dev/null
if ! nix-build --out-link "${TMPDIR}/nix-env" -E "${exp}"; then
  echo "Failed to build dependencies of this script" >&2
  exit 1
fi
popd
export PATH="$(readlink -f "${TMPDIR}/nix-env")/bin"

declare -r omahaproxy='https://omahaproxy.appspot.com'
declare -r bucket_url='https://commondatastorage.googleapis.com/chromium-browser-official'
declare -r deb_url='https://dl.google.com/linux/chrome/deb/pool/main/g'

CHROMIUM_DIR="$(readlink -f "$(readlink -f "$(dirname "$(readlink -f "${0}")")")")"

declare -ra CURL_ARGS=(
  '--continue-at -'
  '--http2'
  '--http2-prior-knowledge'
  '--ssl-reqd'
  '--tlsv1.2'
  '--ciphers ECDHE-RSA-AES256-GCM-SHA384'
  '--proto -all,https'
  '--proto-redir -all,https'
  '--max-redirs 0'
  '--speed-limit 10240'
  '--speed-time 10'
  '--retry 3'
  '--retry-delay 5'
  '--compressed'
  '--create-dirs'
  '--fail'
)

declare -r GOOGLECHROME_PLATFORMS='
[
  {
    "os": "linux",
    "arch": [
      "amd64"
    ]
  }
]
'

declare -A GOOGLECHROME_PLATFORM_ALIASES=(
  ['amd64']='x86_64'
)

declare -a CHROMIUM_CHANNELS=(
  'stable'
  'beta'
  'dev'
)

declare -A CHROME_EQUIVALENT_CHANNEL=(
  # google-chrome refers to dev as unstable
  ['dev']='unstable'
)

declare -a CHROMIUM_LATEST_VERSIONS

version_latest() {
  local -r Channel="${1}"

  curl ${CURL_ARGS[@]} "${omahaproxy}/all.json" -o "${TMPDIR}/all.json"

  Version="$(jq  -r -c -M ".[]|select(.os|contains(\"linux\"))|.versions[]|select(.channel|contains(\"${Channel}\"))|.version" "${TMPDIR}/all.json")"

  [ -n "${Version}" ]

  echo "${Version}"
}

hash_chromium() {
  local -r HashAlgo="${1}"
  local -a Hashes
  local -r Version="${2}"

  [ -n "${Version}" ]

  curl ${CURL_ARGS[@]} "${bucket_url}/chromium-${Version}.tar.xz.hashes" \
    -o "${TMPDIR}/chromium-${Version}.tar.xz.hashes"

  # Maps hashes from checksum file to an array, assumes hashes are
  # always in the same order.
  mapfile -t Hashes < <(
    awk -F'  ' '{print $2}' "${TMPDIR}/chromium-${Version}.tar.xz.hashes"
  )

  # Test incase upstream modifies the checksum file layout
  [ ${#Hashes[5]} -eq 128 ] || {
    echo "ERROR: checksum test failed, returned: ${#Hashes[5]}" 1>&2
    return 1
  }

  case "${HashAlgo}" in
    'md5') echo "${Hashes[0]}" ;;
    'sha1') echo "${Hashes[1]}" ;;
    'sha224') echo "${Hashes[2]}" ;;
    'sha256') echo "${Hashes[3]}" ;;
    'sha384') echo "${Hashes[4]}" ;;
    'sha512') echo "${Hashes[5]}" ;;
  esac
}

hash_google_chrome() {
  local -r Arch="${4}"
  local -r Channel="${2}"
  local Hash
  local -r HashAlgo="${1}"
  local -r Version="${3}"

  curl ${CURL_ARGS[@]} \
    "${deb_url}/google-chrome-${Channel}/google-chrome-${Channel}_${Version}-1_${Arch}.deb" \
    -o "${TMPDIR}/google-chrome-${Channel}_${Version}-1_${Arch}.deb"

  Hash="$(
    openssl ${HashAlgo} \
      "${TMPDIR}/google-chrome-${Channel}_${Version}-1_${Arch}.deb" 2>&- |
      awk -F'= ' '{print $2 ; exit}'
  )"

  [ -n "${Hash}" ]

  echo "${Hash}"
}

sources_chromium() {
  local Version

  for i in "${CHROMIUM_CHANNELS[@]}" ; do
    Version="$(version_latest "${i}")"
    cat <<EOF
  "${i}" = {
    version = "${Version}";
    sha256 = "$(hash_chromium 'sha256' "${Version}")";
  };
EOF
  done
}

sources_google_chrome() {
  local -a ArchPlatforms
  local Channel
  local Name
  local -a OsPlatforms
  local Version

  OsPlatforms=($(
    echo "${GOOGLECHROME_PLATFORMS}" |
      jq -r -c -M '.[].os'
  ))

  for i in "${OsPlatforms[@]}" ; do
    ArchPlatforms=($(
      echo "${GOOGLECHROME_PLATFORMS}" |
        jq -r -c -M ".[]|select(.os|contains(\"${i}\"))|.arch[]"
    ))
    for x in "${ArchPlatforms[@]}" ; do
      Name="${GOOGLECHROME_PLATFORM_ALIASES["${x}"]}"
      Platforms+=("${Name:-${x}}-${i}")
    done
  done

  for i in "${CHROMIUM_CHANNELS[@]}" ; do
    # Determine channel name
    if [ -n "${CHROME_EQUIVALENT_CHANNEL[${i}]}" ] ; then
      Channel="${CHROME_EQUIVALENT_CHANNEL[${i}]}"
    else
      Channel="${i}"
    fi

    echo "  \"${Channel}\" = {"
    Version="$(version_latest "${i}")"
    # FIXME: translate chromium -> chrome channels
    for x in "${Platforms[@]}" ; do
      cat <<EOF
    "${x}" = {
      sha256 = "$(hash_google_chrome 'sha256' "${Channel}" "${Version}" 'amd64')";
    };
EOF
    done
    echo '  };'
  done
}

sources_chromium_generate() {
  cat > "${CHROMIUM_DIR}/sources.nix" <<EOF
# THIS FILE IS AUTOGENERATED, DO NOT EDIT
{ }:
{
$(sources_chromium)
}

EOF
}

sources_google_chrome_generate() {
  cat > "${CHROMIUM_DIR}/../../g/google-chrome/sources.nix" <<EOF
# THIS FILE IS AUTOGENERATED, DO NOT EDIT
{ }:
{
$(sources_google_chrome)
}

EOF
}

main() {
  # Generate chromium/sources.nix
  sources_chromium_generate

  # Generate google-chrome/sources.nix
  sources_google_chrome_generate
}

main

exit 0
