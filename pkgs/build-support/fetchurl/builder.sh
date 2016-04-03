# Convert any non-arrays to arrays
set -o noglob
urls=($urls)
sha512Urls=($sha512Urls)
sha256Urls=($sha256Urls)
sha1Urls=($sha1Urls)
md5Urls=($md5Urls)
minisignUrls=($minisignUrls)
pgpsigUrls=($pgpsigUrls)
pgpKeyIds=($pgpKeyIds)

pgpKeyFingerprints=($pgpKeyFingerprints)

set +o noglob

source $stdenv/setup

downloadedFile="$out"
if [ -n "$downloadToTemp" ]; then downloadedFile="$TMPDIR/file"; fi

# We need to normalize the hash for openssl
HEX_HASH="$(echo "$outputHash" | awk -v algo="$outputHashAlgo" \
'
function ceil(val) {
  if (val == int(val)) {
    return val;
  }
  return int(val) + 1;
}

BEGIN {
  split("0123456789abcdfghijklmnpqrsvwxyz", b32chars, "");
  for (i in b32chars) {
    b32val[b32chars[i]] = i-1;
  }
  split("0123456789abcdef", b16chars, "");
  for (i in b16chars) {
    b16val[b16chars[i]] = i-1;
  }
  if (algo == "sha256") {
    b32len = ceil(256 / 5);
    b16len = 256 / 4;
    blen = 256 / 8;
  } else if (algo == "sha512") {
    b32len = ceil(512 / 5);
    b16len = 512 / 4;
    blen = 512 / 8;
  } else {
    print "Unsupported hash algo" > "/dev/stderr";
    exit(1);
  }
}

{
  len = length($0);
  split($0, chars, "");
  if (len == b32len) {
    split("", bin);
    for (n = 0; n < len; n++) {
      c = chars[len - n];
      digit = b32val[c];
      b = n * 5;
      i = rshift(b, 3);
      j = and(b, 0x7);
      bin[i] = or(bin[i], and(lshift(digit, j), 0xff));
      bin[i+1] = or(bin[i+1], rshift(digit, 8-j));
    }
    out = "";
    for (i = 0; i < blen; i++) {
      out = out b16chars[rshift(bin[i], 4) + 1];
      out = out b16chars[and(bin[i], 0xf) + 1];
    }
    print out;
  } else if (len == b16len) {
    print $0;
  } else {
    print "Unsupported hash encoding" > "/dev/stderr";
  }
}')"

tryDownload() {
  local url
  url="$1"
  local extraOpts
  extraOpts=(
    "-C" "-"
    "--fail"
  )
  local verifications
  verifications=()
  if [ "$2" = "1" ] && echo "$url" | grep -q '^https' && echo "$curlOpts" | grep -q -v '\--insecure'; then
    verifications+=('https')
    extraOpts+=('--ssl-reqd')
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
        if [ -n "$sha512Confirm" ]; then
          local sha512
          sha512="$(openssl sha512 -r -hex "$out" 2>/dev/null | tail -n 1 | awk '{print $1}')"
          if [ "$sha512Confirm" != "$sha512" ]; then
            echo "$out SHA512 hash does not match given $sha512Confirm" >&2
            break
          else
            verifications+=('sha512')
          fi
        fi

        if [ -n "$sha256Confirm" ]; then
          local sha256
          sha256="$(openssl sha256 -r -hex "$out" 2>/dev/null | tail -n 1 | awk '{print $1}')"
          if [ "$sha256Confirm" != "$sha256" ]; then
            echo "$out SHA256 hash does not match given $sha256Confirm" >&2
            break
          else
            verifications+=('sha256')
          fi
        fi

        if [ -n "$sha1Confirm" ]; then
          local sha1
          sha1="$(openssl sha1 -r -hex "$out" 2>/dev/null | tail -n 1 | awk '{print $1}')"
          if [ "$sha1Confirm" != "$sha1" ]; then
            echo "$out SHA1 hash does not match given $sha1Confirm" >&2
            break
          else
            verifications+=('sha1')
          fi
        fi

        if [ -n "$md5Confirm" ]; then
          local md5
          md5="$(openssl md5 -r -hex "$out" 2>/dev/null | tail -n 1 | awk '{print $1}')"
          if [ "$md5Confirm" != "$md5" ]; then
            echo "$out MD5 hash does not match given $md5Confirm" >&2
            break
          else
            verifications+=('md5')
          fi
        fi

        if [ -n "$minisignPub" ]; then
          if ! minisign -V -x "$TMPDIR/minisign" -m "$out" -P "$minisignPub" -q; then
            echo "$out Minisig does not validate" >&2
            break
          else
            verifications+=('minisign')
          fi
        fi

        if [ -n "$pgpKeyFile" ] || [ "${#pgpKeyIds[@]}" -gt "0" ]; then
          if ! gpg --lock-never --verify "$TMPDIR/pgpsig" "$out"; then
            echo "$out pgpsig does not validate" >&2
            break
          else
            verifications+=('pgp')
          fi
        fi

        runHook postVerification

        local lhash
        lhash="$(openssl "$outputHashAlgo" -r -hex "$out" 2>/dev/null | awk '{print $1;}')"
        if [ "$lhash" = "$HEX_HASH" ]; then
          success=1
        else
          rm -f $out
          rm -f $downloadedFile
          str="Got a bad hash:\n"
          str+="  URL: $url\n"
          str+="  File: $out\n"
          if [ -n "$allowHashOutput" ] && [ "${#verifications[@]}" -gt 0 ]; then
            str+='  Verification:'
            local verification
            for verification in "${verifications[@]}"; do
              str+=" $verification"
            done
            str+="\n  sha256: $lhash"
          fi
          echo -e "$str" >&2
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

  array="${varname}[@]"
  for url in "${!array}"; do
    if test "${url:0:9}" != "mirror://"; then
      result+=("$url")
    else
      local mirror
      mirror="$(echo "$url" | awk -F/ '{print $3}')"
      base="$(echo "$url" | awk -F/ '{ for (i=4; i<=NF; i++) { printf "%s", "/" $i; } }')"
      while read mirror; do
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
}

fixUrls 'urls'
fixUrls 'sha512Urls'
fixUrls 'sha256Urls'
fixUrls 'sha1Urls'
fixUrls 'md5Urls'
fixUrls 'minisignUrls'
fixUrls 'pgpsigUrls'

if test -n "$showURLs"; then
  echo "URLs:"
  for url in "${urls[@]}"; do
    echo "  $url" >&2
  done

  if [ "${#sha512Urls[@]}" -gt 0 ]; then
    echo "sha512 URLs:"
    for url in "${sha512Urls[@]}"; do
      echo "  $url" >&2
    done
  fi

  if [ "${#sha256Urls[@]}" -gt 0 ]; then
    echo "sha256 URLs:"
    for url in "${sha256Urls[@]}"; do
      echo "  $url" >&2
    done
  fi

  if [ "${#sha1Urls[@]}" -gt 0 ]; then
    echo "sha1 URLs:"
    for url in "${sha1Urls[@]}"; do
      echo "  $url" >&2
    done
  fi

  if [ "${#md5Urls[@]}" -gt 0 ]; then
    echo "md5 URLs:"
    for url in "${md5Urls[@]}"; do
      echo "  $url" >&2
    done
  fi

  if [ "${#minisignUrls[@]}" -gt 0 ]; then
    echo "Minisign URLs:"
    for url in "${minisignUrls[@]}"; do
      echo "  $url" >&2
    done
  fi

  if [ "${#pgpsigUrls[@]}" -gt 0 ]; then
    echo "ASC URLs:"
    for url in "${pgpsigUrls[@]}"; do
      echo "  $url" >&2
    done
  fi
fi

runHook preFetch

if ! test -f /etc/ssl/certs/ca-certificates.crt; then
  echo "Warning, downloading without validating SSL cert." >&2
  echo "Eventually this will be disallowed completely." >&2
  curlOpts="$curlOpts --insecure"
fi
export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

# Curl flags to handle redirects, not use EPSV, handle cookies for
# servers to need them during redirects, and work on SSL without a
# certificate (this isn't a security problem because we check the
# cryptographic hash of the output anyway).
curl="curl \
 --location --max-redirs 20 \
 --retry 3 \
 --disable-epsv \
 --cookie-jar cookies \
 --speed-limit 10240 \
 --speed-time 5 \
 $curlOpts \
 $NIX_CURL_FLAGS"

# Import needed gnupg keys
HOME="$TMPDIR"  # GNUPG needs this
if [ -n "$pgpKeyFile" ]; then
  gpg --import "$pgpKeyFile"
fi

if [ "${#pgpKeyIds[@]}" -gt "0" ]; then
  gpg --list-keys
  eval `dirmngr --daemon --homedir=$HOME --disable-http --disable-ldap`
  gpg --verbose --recv-keys --keyserver "hkp://pgp.mit.edu" "${pgpKeyIds[@]}"
fi

i=0
while [ "$i" -lt "${#pgpKeyIds[@]}" ]; do
  pgpKeyId="${pgpKeyIds[$i]}"
  pgpKeyFingerprint="${pgpKeyFingerprints[$i]}"
  if [ "$(gpg --fingerprint "$pgpKeyId" | awk -F '= ' '{ if (/Key fingerprint/) { gsub(/ /, "", $2); print $2; } }')" != "$pgpKeyFingerprint" ]; then
    echo "Fingerprints didn't match for $pgpKeyId" >&2
    exit 1
  fi
  i=$(($i + 1))
done

# We want to download signatures first
getHashOrEmpty() {
  if grep -q "$(basename "$urls")" "$1"; then
    grep "$(basename "$urls")" "$1" | awk '{ print $1 }'
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

for url in "${sha512Urls[@]}"; do
  echo "Trying $url" >&2
  if $curl -C - --fail "$url" --output "$TMPDIR/sha512"; then
    sha512Confirm="$(getHash "$TMPDIR/sha512")"
    break
  else
    sha512Confirm="broken"
  fi
done

for url in "${sha256Urls[@]}"; do
  echo "Trying $url" >&2
  if $curl -C - --fail "$url" --output "$TMPDIR/sha256"; then
    sha256Confirm="$(getHash "$TMPDIR/sha256")"
    break
  else
    sha256Confirm="broken"
  fi
done

for url in "${sha1Urls[@]}"; do
  echo "Trying $url" >&2
  if $curl -C - --fail "$url" --output "$TMPDIR/sha1"; then
    sha1Confirm="$(getHash "$TMPDIR/sha1")"
    break
  else
    sha1Confirm="broken"
  fi
done

for url in "${md5Urls[@]}"; do
  echo "Trying $url" >&2
  if $curl -C - --fail "$url" --output "$TMPDIR/md5"; then
    md5Confirm="$(getHash "$TMPDIR/md5")"
    break
  else
    md5Confirm="broken"
  fi
done

for url in "${minisignUrls[@]}"; do
  echo "Trying $url" >&2
  if $curl -C - --fail "$url" --output "$TMPDIR/minisign"; then
    break
  else
    rm -f "$TMPDIR/minisign"
  fi
done

for url in "${pgpsigUrls[@]}"; do
  echo "Trying $url" >&2
  if $curl -C - --fail "$url" --output "$TMPDIR/pgpsig"; then
    break
  else
    rm -f "$TMPDIR/pgpsig"
  fi
done

# Download the actual file
if [ -n "$multihash" ]; then
  if [ -n "$IPFS_API" ]; then
    tryDownload "http://$IPFS_API/ipfs/$multihash"
  fi
  tryDownload "http://127.0.0.1/ipfs/$multihash"
  tryDownload "http://127.0.0.1:8080/ipfs/$multihash"
fi

for url in "${urls[@]}"; do
  tryDownload "$url" "1"
done

# We only ever want to access the official gateway as a last resort as it can be slow
if [ -n "$multihash" ]; then
  tryDownload "https://gateway.ipfs.io/ipfs/$multihash"
fi


echo "error: cannot download $name from any mirror"
exit 1
