# Convert any non-arrays to arrays
set -o noglob
urls=($urls)
sha512Urls=($sha512Urls)
sha256Urls=($sha256Urls)
sha1Urls=($sha1Urls)
md5Urls=($md5Urls)
minisignUrls=($minisignUrls)
pgpsigUrls=($pgpsigUrls)
pgpsigMd5Urls=($pgpsigMd5Urls)
pgpsigSha1Urls=($pgpsigSha1Urls)
pgpsigSha256Urls=($pgpsigSha256Urls)
pgpsigSha512Urls=($pgpsigSha512Urls)
signifyUrls=($signifyUrls)

pgpKeyFingerprints=($pgpKeyFingerprints)

set +o noglob

source $stdenv/setup

str="Environment: $name\n"
str+="  HTTP_PROXY: $HTTP_PROXY\n"
str+="  HTTPS_PROXY: $HTTPS_PROXY\n"
str+="  FTP_PROXY: $FTP_PROXY\n"
str+="  ALL_PROXY: $ALL_PROXY\n"
str+="  NO_PROXY: $NO_PROXY\n"
str+="  NIX_CURL_FLAGS: $NIX_CURL_FLAGS\n"
echo -e "$str" 2>&1

downloadedFile="$out"
if [ -n "$downloadToTemp" ]; then downloadedFile="$TMPDIR/file"; fi

# Figure out the output hash
if [ -z "$outputHashAlgo" ]; then
  outputHashAlgo="${outputHash%:*}"
  outputHash="${outputHash#*:}"
fi

# We need to normalize the hash for openssl
HEX_HASH="$(transcodeHash base16 "$outputHash" "$outputHashAlgo")"

tryDownload() {
  local url
  url="$1"
  local typ
  typ="$2"
  local extraOpts
  extraOpts=(
    "--continue-at" "-"
    "--fail"
  )
  local verifications
  verifications=()
  if [ -n "$insecureHashOutput" ]; then
    verifications+=('insecure')
  fi
  if echo "$url" | grep -q '^https'; then
    extraOpts+=('--ssl-reqd')
    if [ "$typ" != "main" ] || [ "$insecureProtocolDowngrade" != "1" ]; then
      extraOpts+=('--proto-redir' '-all,https')
    fi
    if [ "$typ" = "main" ] && [ "$insecureProtocolDowngrade" != "1" ] && echo "$curlOpts" | grep -q -v '\--insecure'; then
      verifications+=('https')
    fi
  fi

  echo
  header "trying $url"
  local curlexit=18;

  local success
  success=0

  # if we get error code 18, resume partial download
  while [ $curlexit -eq 18 ]; do
    # keep this inside an if statement, since on failure it doesn't abort the script
    if $curl "${extraOpts[@]}" "$url" --output "$downloadedFile"; then
      runHook postFetch
      if [ "$outputHashMode" = "flat" ]; then
        if [ "$typ" = "main" ]; then
          if [ -n "$sha512Confirm" ]; then
            local sha512
            sha512="$(openssl sha512 -r -hex "$out" 2>/dev/null | tail -n 1 | awk '{print $1}')"
            if [ "$sha512Confirm" != "$sha512" ]; then
              echo "$out SHA512 hash does not match given $sha512Confirm" >&2
              if [ "$failEarly" = "1" ]; then
                exit 1
              else
                break
              fi
            else
              verifications+=("${sha512Verification:-sha512}")
            fi
          fi

          if [ -n "$sha256Confirm" ]; then
            local sha256
            sha256="$(openssl sha256 -r -hex "$out" 2>/dev/null | tail -n 1 | awk '{print $1}')"
            if [ "$sha256Confirm" != "$sha256" ]; then
              echo "$out SHA256 hash does not match given $sha256Confirm" >&2
              if [ "$failEarly" = "1" ]; then
                exit 1
              else
                break
              fi
            else
              verifications+=("${sha256Verification:-sha256}")
            fi
          fi

          if [ -n "$sha1Confirm" ]; then
            local sha1
            sha1="$(openssl sha1 -r -hex "$out" 2>/dev/null | tail -n 1 | awk '{print $1}')"
            if [ "$sha1Confirm" != "$sha1" ]; then
              echo "$out SHA1 hash does not match given $sha1Confirm" >&2
              if [ "$failEarly" = "1" ]; then
                exit 1
              else
                break
              fi
            else
              verifications+=("${sha1Verification:-sha1}")
            fi
          fi

          if [ -n "$md5Confirm" ]; then
            local md5
            md5="$(openssl md5 -r -hex "$out" 2>/dev/null | tail -n 1 | awk '{print $1}')"
            if [ "$md5Confirm" != "$md5" ]; then
              echo "$out MD5 hash does not match given $md5Confirm" >&2
              if [ "$failEarly" = "1" ]; then
                exit 1
              else
                break
              fi
            else
              verifications+=("${md5Verification:-md5}")
            fi
          fi

          if [ -n "$minisignPub" ]; then
            if ! minisign -V -x "$TMPDIR/minisign" -m "$out" -P "$minisignPub"; then
              echo "$out Minisig does not validate" >&2
              if [ "$failEarly" = "1" ]; then
                exit 1
              else
                break
              fi
            else
              verifications+=('minisign')
            fi
          fi

          if [ "${#pgpsigUrls[@]}" -gt "0" ]; then
            method="cat \"$out\""
            if [ "${pgpDecompress}" = "1" ]; then
              case "$out" in
                *.bz2 | *.tbz2)
                  method="bzip2 -d -c \"$out\""
                  ;;
                *.gz | *.tgz)
                  method="gzip -d -c \"$out\""
                  ;;
                *.xz | *.txz)
                  method="xz -d -c \"$out\""
                  ;;
                *)
                  echo "Could not determine how to decompress $out for pgp verification" >&2
                  exit 1
                  ;;
              esac
            fi
            if ! gpg --lock-never --verify "$TMPDIR/pgpsig" - < <(eval $method); then
              echo "$out pgpsig does not validate" >&2
              if [ "$failEarly" = "1" ]; then
                exit 1
              else
                break
              fi
            else
              verifications+=('pgp')
            fi
          fi
          if [ -n "$signifyPub" ]; then
            echo "untrusted comment: signify public key" > "$TMPDIR/signify.pub"
            echo "$signifyPub" >> "$TMPDIR/signify.pub"
            ln -s "$out" "$name"
            if ! signify -C -p "$TMPDIR/signify.pub" -x "$TMPDIR/signify"; then
              echo "$out Signify does not validate" >&2
              if [ "$failEarly" = "1" ]; then
                exit 1
              else
                break
              fi
            else
              verifications+=('signify')
            fi
          fi
        fi

        runHook postVerification

        local lhash
        lhash="$(openssl "$outputHashAlgo" -r -hex "$out" 2>/dev/null | awk '{print $1;}')"
        if [ "$lhash" = "${HEX_HASH,,}" ]; then
          success=1
        else
          rm -f $out
          rm -f $downloadedFile
          str="Got a bad hash:\n"
          str+="  URL: $url\n"
          str+="  File: $out\n"
          if [ -n "$hashOutput" ] && [ "${#verifications[@]}" -gt 0 ]; then
            str+='  Verification:'
            local verification
            for verification in "${verifications[@]}"; do
              str+=" $verification"
            done
            str+="\n  Hash: $outputHashAlgo:$lhash"
          fi
          echo -e "$str" >&2
          if [ "$failEarly" = "1" ]; then
            exit 1
          fi
        fi
        break
      else
        runHook postVerification
        success=1
        break
      fi
    else
      curlexit=$?;
    fi
  done

  if [ "$success" = "1" ]; then
    if [ "$executable" = "1" ]; then
      chmod +x $out
    fi
    exit 0
  fi

  stopNest
}

fixUrls() {
  local varname
  varname="$1"

  local result
  result=()

  local array
  array="${varname}[@]"
  local url
  for url in "${!array}"; do
    if test "${url:0:9}" != "mirror://"; then
      result+=("$url")
    else
      local mirror
      mirror="$(echo "$url" | awk -F/ '{print $3}')"
      local base
      base="$(echo "$url" | awk -F/ '{ for (i=4; i<=NF; i++) { printf "%s", "/" $i; } }')"
      while read mirror; do
        eval mirror="\"$mirror\""
        result+=("$mirror$base")
      done < <(awk -v mirror="$mirror" '{
          if ($0 ~ "^" mirror " ") {
            for (i=2; i<=NF; i++) {
              print $i;
            }
          }
        }' "$mirrorsFile")
    fi
  done

  eval $varname='("${result[@]}")'

  if test -n "$showURLs"; then
    echo "${varname}:" >&2
    for url in "${!array}"; do
      echo "  $url" >&2
    done
  fi
}

fixUrls 'urls'
fixUrls 'sha512Urls'
fixUrls 'sha256Urls'
fixUrls 'sha1Urls'
fixUrls 'md5Urls'
fixUrls 'minisignUrls'
fixUrls 'pgpsigUrls'
fixUrls 'pgpsigMd5Urls'
fixUrls 'pgpsigSha1Urls'
fixUrls 'pgpsigSha256Urls'
fixUrls 'pgpsigSha512Urls'
fixUrls 'signifyUrls'

export SSL_CERT_FILE=${SSL_CERT_FILE-/etc/ssl/certs/ca-certificates.crt}
if ! test -f "$SSL_CERT_FILE"; then
  echo "ERROR: downloading without validating SSL cert." >&2
  echo "Please check $SSL_CERT_FILE" >&2
  exit 1
fi

# Curl flags to handle redirects, not use EPSV, handle cookies for
# servers to need them during redirects, and work on SSL without a
# certificate (this isn't a security problem because we check the
# cryptographic hash of the output anyway).
curl="curl \
 --location --max-redirs 20 \
 --connect-timeout 5 \
 --retry 3 \
 --disable-epsv \
 --cookie-jar cookies \
 --speed-limit 10240 \
 --speed-time 10 \
 $curlOpts \
 $NIX_CURL_FLAGS"

runHook preFetch

# Download the actual file from ipfs before doing anything else
if [ -n "$multihash" ]; then
  ipfsUrls="mirror://ipfs-cached/ipfs/$multihash"
  fixUrls 'ipfsUrls'
  for url in "${ipfsUrls[@]}"; do
    tryDownload "$url" "ipfs"
  done
fi

# Import needed gnupg keys
HOME="$TMPDIR"  # GNUPG needs this
if [ -n "$pgpKeyFile" ]; then
  gpg --import "$pgpKeyFile"
fi

cleanup() {
  CODE="$?"
  # Make sure DIRMNGR is dead so the build completes
  if [ -n "$DIRMNGR_INFO" ]; then
    kill -9 $(echo "$DIRMNGR_INFO" | awk -F: '{print $2}')
  fi
  trap - EXIT ERR INT QUIT PIPE TERM
  exit "$CODE"
}
trap cleanup EXIT ERR INT QUIT PIPE TERM

mkdir -m 0700 -p "$HOME/.gnupg"
echo "keyserver hkps://hkps.pool.sks-keyservers.net" >> "$HOME/.gnupg/gpg.conf"
echo "no-auto-key-retrieve" >> "$HOME/.gnupg/gpg.conf"
echo "auto-key-locate local" >> "$HOME/.gnupg/gpg.conf"
echo "trust-model always" >> "$HOME/.gnupg/gpg.conf"
if [ "${#pgpKeyFingerprints[@]}" -gt "0" ]; then
  eval `dirmngr --verbose --daemon --homedir=$HOME/.gnupg --disable-http --disable-ldap --allow-ocsp --no-use-tor`
  gpg --verbose --recv-keys "${pgpKeyFingerprints[@]}"
fi

i=0
while [ "$i" -lt "${#pgpKeyFingerprints[@]}" ]; do
  pgpKeyFingerprint="${pgpKeyFingerprints[$i]}"
  if [ "$(gpg --fingerprint "$pgpKeyFingerprint" | sed '2s, ,,g' | head -n 2 | tail -n -1)" != "$pgpKeyFingerprint" ]; then
    echo "Fingerprints didn't match for $pgpKeyFingerprint" >&2
    exit 1
  fi
  i=$(($i + 1))
done

auxDownload() {
  local url
  url="$1"
  local output
  output="$2"

  local extraOpts
  extraOpts=()
  if echo "$url" | grep -q '^https'; then
    extraOpts+=('--ssl-reqd')
    if [ "$insecureProtocolDowngrade" != "1" ]; then
      extraOpts+=('--proto-redir' '-all,https')
    fi

    if [ "$insecureProtocolDowngrade" != "1" ] && echo "$curlOpts" | grep -q -v '\--insecure'; then
      usedHttps=
    else
      unset usedHttps
    fi
  else
    unset usedHttps
  fi

  echo "Trying $url" >&2
  if $curl "${extraOpts[@]}" --continue-at - --fail "$url" --output "$output"; then
    return 0
  else
    rm -f "$output"
    return 1
  fi
}

# Download sig files
sigDownload() {
  local varname
  varname="$1"

  local urlsVar
  urlsVar="${varname}Urls[@]"
  for url in "${!urlsVar}"; do
    auxDownload "$url" "$TMPDIR/$varname" && break
  done
}
sigDownload "minisign"
sigDownload "pgpsig"
sigDownload "pggsigMd5"
sigDownload "pgpsigSha1"
sigDownload "pgpsigSha256"
sigDownload "pgpsigSha512"
sigDownload "signify"

# We want to download signatures first
getHashOrEmpty() {
  local match_expr
  match_expr="\( \|\t\|/\|(\|\*\)$(basename "$urls")\()\| \|\t\|$\)"
  if grep -q "$match_expr" "$1"; then
    grep "$match_expr" "$1" | sed -n "s,.*\\([0-9A-Za-z]\\{$2\\}\\).*,\\1,p"
  else
    cat "$1"
  fi
}

getHash() {
  local hashh
  hashh="$(getHashOrEmpty "$@")"
  if [ -z "$hashh" ]; then
    echo "broken"
  else
    echo "$hashh"
  fi
}

getHashConfirmation() {
  local varname
  varname="$1"
  local size
  size="$2"

  local urlsVar
  urlsVar="${varname}Urls[@]"
  for url in "${!urlsVar}"; do
    if ! auxDownload "$url" "$TMPDIR/$varname"; then
      eval "${varname}Confirm"='"broken"'
      continue
    fi
    if echo "$url" | grep -q '\.\(asc\|sig\|sign\)$'; then
      mv "$TMPDIR/$varname" "$TMPDIR/$varname.asc"
      if ! gpg --lock-never --output "$TMPDIR/$varname" --decrypt "$TMPDIR/$varname.asc"; then
        echo "$TMPDIR/$varname.asc pgpsig does not validate" >&2
        exit 1
      fi
      eval "${varname}Verification"='"${usedHttps+https*}pgp*${varname}"'
      eval "${varname}Confirm"='"$(getHash "$TMPDIR/$varname" "$size")"'
      break
    else
      local numPgpUrls
      eval 'numPgpUrls'="\"\${#pgpsig${varname^}Urls[@]}\""
      if [ "$numPgpUrls" -gt "0" ]; then
         if ! gpg --lock-never --verify "$TMPDIR/pgpsig${varname^}" "$TMPDIR/${varname}"; then
            echo "$TMPDIR/${varname} pgpsig does not validate" >&2
            exit 1
         fi
         eval "${varname}Verification"='"pgp*"'
      fi
      eval "${varname}Verification"="\"\${usedHttps+https*}\${${varname}Verification}${varname}\""
      eval "${varname}Confirm"='"$(getHash "$TMPDIR/$varname" "$size")"'
      break
    fi
  done
}

getHashConfirmation 'md5'    '32'
getHashConfirmation 'sha1'   '40'
getHashConfirmation 'sha256' '64'
getHashConfirmation 'sha512' '128'

# Try to download from the main mirrors
for url in "${urls[@]}"; do
  tryDownload "$url" "main"
done

# We only ever want to access the official gateway as a last resort as it can be slow
if [ -n "$multihash" ]; then
  ipfsUrls="mirror://ipfs-nocache/ipfs/$multihash"
  fixUrls 'ipfsUrls'
  for url in "${ipfsUrls[@]}"; do
    tryDownload "$url" "ipfs"
  done
fi


echo "error: Failed to produce $name from any mirror"
exit 1
