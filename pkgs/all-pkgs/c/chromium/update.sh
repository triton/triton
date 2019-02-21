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
  trap - EXIT ERR INT QUIT PIPE TERM
  exit "$CODE"
}
trap cleanup EXIT ERR INT QUIT PIPE TERM
export TMPDIR="$(mktemp -d /tmp/chromium-updater.XXXXXXXXXX)"

# Find the top git level
TOP_LEVEL="$(pwd)"
while ! [ -e "${TOP_LEVEL}/.git" ]; do
  if [ "$(readlink -f "$TOP_LEVEL")" = "/" ]; then
    echo "Failed to find git directory" >&2
    exit 1
  fi
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
    gnused
    jq
    openssl
    perl
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

declare -r CHROMIUM_DIR="$(
  readlink -f "$(readlink -f "$(dirname "$(readlink -f "${0}")")")"
)"

declare -ra CURL_ARGS=(
  '--continue-at' '-'
  '--http2'
  '--http2-prior-knowledge'
  '--ssl-reqd'
  '--tlsv1.2'
  #'--ciphers' 'ECDHE-RSA-AES256-GCM-SHA384'
  '--proto' '-all,https'
  '--proto-redir' '-all,https'
  '--max-redirs' '0'
  '--speed-limit' '10240'
  '--speed-time' '10'
  '--retry' '3'
  '--retry-delay' '5'
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

# Convert sources.nix to json for parsing
# FIXME: use nix to read attrs
sources_to_json() {
  local -r File="${1}"

  if [ ! -f "${File}" ] ; then
    echo "ERROR: sources_to_json requires a file: ${File}" >&2
    return 1
  fi

  tail -n +3 "${File}" |
    sed -e 's/ =/:/' \
    -e 's/;/,/' \
    -e '/sha256/ s/,//' \
    -e 's/version/"version"/' \
    -e 's/sha256/"sha256"/' \
    -e 's/    },/    }/' \
    -e '$s/,$//g' |
    perl -00pe 's/,(?!.*,)//s'
}

version_latest() {
  local -r Channel="${1}"

  echo "${omahaproxy}/all.json" >&2
  curl ${CURL_ARGS[@]} "${omahaproxy}/all.json" -o "${TMPDIR}/all.json"

  Version="$(
    jq  -r -c -M ".[]|select(.os|contains(\"linux\"))|.versions[]|select(.channel|contains(\"${Channel}\"))|.version" \
      "${TMPDIR}/all.json"
  )"

  [ -n "${Version}" ]

  echo "${Version}"
}

hash_chromium() {
  local -r HashAlgo="${1}"
  local -a Hashes
  local -r Version="${2}"

  echo "${bucket_url}/chromium-${Version}.tar.xz.hashes" >&2
  # Don't overwrite file, multiple channels may be on the same version.
  if [ ! -f "${TMPDIR}/chromium-${Version}.tar.xz.hashes" ] ; then
    curl ${CURL_ARGS[@]} "${bucket_url}/chromium-${Version}.tar.xz.hashes" \
      -o "${TMPDIR}/chromium-${Version}.tar.xz.hashes" || {
      echo "ERROR: Failed to retrieve hash file for version: ${Version}" >&2
      return 1
    }
  fi

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

  echo "${deb_url}/google-chrome-${Channel}/google-chrome-${Channel}_${Version}-1_${Arch}.deb" >&2
  curl ${CURL_ARGS[@]} \
    "${deb_url}/google-chrome-${Channel}/google-chrome-${Channel}_${Version}-1_${Arch}.deb" \
    -o "${TMPDIR}/google-chrome-${Channel}_${Version}-1_${Arch}.deb" || {
    echo "ERROR: Failed to retrieve google-chrome deb for channel/version: ${Channel}/${Version}" >&2
    return 1
  }

  Hash="$(
    openssl ${HashAlgo} \
      "${TMPDIR}/google-chrome-${Channel}_${Version}-1_${Arch}.deb" 2>&- |
      awk -F'= ' '{print $2 ; exit}'
  )"

  [ -n "${Hash}" ]

  echo "${Hash}"
}

sources_chromium() {
  local ChromiumHash
  local Version
  local ChromiumPreviousJson

  ChromiumPreviousJson="$(sources_to_json "${CHROMIUM_DIR}/sources.nix")"

  for i in "${CHROMIUM_CHANNELS[@]}" ; do
    Version="$(version_latest "${i}")"
    ChromiumHash="$(hash_chromium 'sha256' "${Version}")" || {
      echo -e "\e[31mFalling back to previous channel version\e[0m" >&2
      Version="$(
        echo "${ChromiumPreviousJson}" | jq -r -c -M ".${i}.version"
      )"
      echo -e "\e[33m Version: ${Version}\e[0m" >&2
      ChromiumHash="$(
        echo "${ChromiumPreviousJson}" | jq -r -c -M ".${i}.sha256"
      )"
      echo -e "\e[33m ChromiumHash: ${ChromiumHash}\e[0m" >&2
    }
    echo -e "\e[33mChromium: channel=${i} version=${Version}\e[0m" >&2
    cat <<EOF
  "${i}" = {
    version = "${Version}";
    sha256 = "${ChromiumHash}";
  };
EOF
  done
}

sources_google_chrome() {
  local -a ArchPlatforms
  local Channel
  local GoogleChromeHash
  local GoogleChromePreviousJson
  local Name
  local -a OsPlatforms
  local Version
  local VersionChromium
  local VersionLatest

  OsPlatforms=($(
    echo "${GOOGLECHROME_PLATFORMS}" |
      jq -r -c -M '.[].os'
  ))

  GoogleChromePreviousJson="$(
    sources_to_json "${CHROMIUM_DIR}/../../g/google-chrome/sources.nix"
  )"

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
    VersionChromium="$(
      sources_to_json "${CHROMIUM_DIR}/sources.nix" |
        jq -r -c -M ".${i}.version"
    )"
    VersionLatest="$(version_latest "${i}")"
    if [ "${VersionLatest}" != "${VersionChromium}" ] ; then
      Version="${VersionChromium}"
    else
      Version="${VersionLatest}"
    fi
    # FIXME: translate chromium -> chrome channels
    for x in "${Platforms[@]}" ; do
      echo -e "\e[33mGoogle Chrome: channel=${Channel} version=${Version} arch=FIXME\e[0m" >&2
      if [ "${VersionLatest}" != "${VersionChromium}" ] ; then
        GoogleChromeHash="$(
          echo "${GoogleChromePreviousJson}" |
            jq -r -c -M ".${Channel}.\"${x}\".sha256"
        )"
      else
        GoogleChromeHash="$(
          hash_google_chrome 'sha256' "${Channel}" "${Version}" 'amd64'
        )"
      fi
      cat <<EOF
    "${x}" = {
      sha256 = "${GoogleChromeHash}";
    };
EOF
    done
    echo '  };'
  done
}

sources_chromium_generate() {
  local ChromiumSources

  # sources_chromium must be called before sources.nix is overwritten
  ChromiumSources="$(sources_chromium)"

  cat > "${CHROMIUM_DIR}/sources.nix" <<EOF
# THIS FILE IS AUTOGENERATED, DO NOT EDIT
{ }:
{
${ChromiumSources}
}

EOF
}

sources_google_chrome_generate() {
  local GoogleChromeSources

  # sources_google_chrome must be called before sources.nix is overwritten
  GoogleChromeSources="$(sources_google_chrome)"

  cat > "${CHROMIUM_DIR}/../../g/google-chrome/sources.nix" <<EOF
# THIS FILE IS AUTOGENERATED, DO NOT EDIT
{ }:
{
${GoogleChromeSources}
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
