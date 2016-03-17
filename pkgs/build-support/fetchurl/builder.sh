source $stdenv/setup

source $mirrorsFile

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
  local canPrintHash
  canPrintHash="$2"

  echo
  header "trying $url"
  local curlexit=18;

  local success
  success=0

  # if we get error code 18, resume partial download
  while [ $curlexit -eq 18 ]; do
    # keep this inside an if statement, since on failure it doesn't abort the script
    if $curl -C - --fail "$url" --output "$downloadedFile"; then
      set +o noglob
      runHook postFetch
      set -o noglob
      if [ "$outputHashMode" = "flat" ]; then
        if [ -n "$sha1Confirm" ]; then
          local sha1
          sha1="$(openssl sha1 -r -hex "$out" 2>/dev/null | tail -n 1 | awk '{print $1}')"
          if [ "$sha1Confirm" != "$sha1" ]; then
            echo "$out SHA1 hash does not match given $sha1Confirm" >&2
            break
          fi
        fi

        if [ -n "$md5Confirm" ]; then
          local md5
          md5="$(openssl md5 -r -hex "$out" 2>/dev/null | tail -n 1 | awk '{print $1}')"
          if [ "$md5Confirm" != "$md5" ]; then
            echo "$out MD5 hash does not match given $md5Confirm" >&2
            break
          fi
        fi

        local lhash
        lhash="$(openssl "$outputHashAlgo" -r -hex "$out" 2>/dev/null | awk '{print $1;}')"
        if [ "$lhash" = "$HEX_HASH" ]; then
          success=1
        else
          rm -f $out
          rm -f $downloadedFile
          str="$url produced a bad hash for $out"
          if [ "$canPrintHash" = "1" ] && echo "$url" | grep -q 'https'; then
            str+=": $lhash"
          fi
          echo "$str" >&2
        fi
        break
      else
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


# URL list may contain ?. No glob expansion for that, please
set -o noglob

urls2=
for url in $urls; do
    if test "${url:0:9}" != "mirror://"; then
        urls2="$urls2 $url"
    else
        url2="${url:9}"; echo "${url2/\// }" > split; read site fileName < split
        #varName="mirror_$site"
        varName="$site" # !!! danger of name clash, fix this
        if test -z "${!varName}"; then
            echo "warning: unknown mirror:// site \`$site'"
        else
            # Assume that SourceForge/GNU/kernel mirrors have better
            # bandwidth than nixos.org.
            preferHashedMirrors=

            mirrors=${!varName}

            # Allow command-line override by setting NIX_MIRRORS_$site.
            varName="NIX_MIRRORS_$site"
            if test -n "${!varName}"; then mirrors="${!varName}"; fi

            for url3 in $mirrors; do
                urls2="$urls2 $url3$fileName";
            done
        fi
    fi
done
urls="$urls2"

# Restore globbing settings
set +o noglob

if test -n "$showURLs"; then
    echo "$urls" > $out
    exit 0
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
 $curlOpts \
 $NIX_CURL_FLAGS"


if [ -n "$multihash" ]; then
  if [ -n "$IPFS_ADDR" ]; then
    tryDownload "http://$IPFS_ADDR/ipfs/$multihash"
  fi
  tryDownload "http://127.0.0.1/ipfs/$multihash"
  tryDownload "http://127.0.0.1:8080/ipfs/$multihash"
fi

# URL list may contain ?. No glob expansion for that, please
set -o noglob

for url in $urls; do
  tryDownload "$url" "1"
done

# Restore globbing settings
set +o noglob

# We only ever want to access the official gateway as a last resort as it can be slow
if [ -n "$multihash" ]; then
  tryDownload "https://gateway.ipfs.io/ipfs/$multihash"
fi


echo "error: cannot download $name from any mirror"
exit 1
