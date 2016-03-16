source $stdenv/setup

source $mirrorsFile


downloadedFile="$out"
if [ -n "$downloadToTemp" ]; then downloadedFile="$TMPDIR/file"; fi


tryDownload() {
    local url="$1"
    echo
    header "trying $url"
    local curlexit=18;

    success=

    # if we get error code 18, resume partial download
    while [ $curlexit -eq 18 ]; do
       # keep this inside an if statement, since on failure it doesn't abort the script
       if $curl -C - --fail "$url" --output "$downloadedFile"; then
          success=1
          break
       else
          curlexit=$?;
       fi
    done
    stopNest
}


finish() {
    set +o noglob

    if [[ $executable == "1" ]]; then
      chmod +x $downloadedFile
    fi

    if [ -n "$sha1Confirm" ]; then
      sha1="$(openssl sha1 -r "$downloadedFile" | tail -n 1 | awk '{print $1}')"
      if [ "$sha1Confirm" != "$sha1" ]; then
        echo "SHA1 hash does not match given $sha1Confirm" >&2
        exit 1
      fi
    fi

    if [ -n "$md5Confirm" ]; then
      md5="$(openssl md5 -r "$downloadedFile" | tail -n 1 | awk '{print $1}')"
      if [ "$md5Confirm" != "$md5" ]; then
        echo "MD5 hash does not match given $md5Confirm" >&2
        exit 1
      fi
    fi

    runHook postFetch
    stopNest
    exit 0
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


# URL list may contain ?. No glob expansion for that, please
set -o noglob

success=
if [ -n "$multihash" ]; then
  if [ -n "$IPFS_ADDR" ]; then
    tryDownload "http://$IPFS_ADDR/ipfs/$multihash"
    if test -n "$success"; then
      finish
    fi
  fi

  tryDownload "http://127.0.0.1/ipfs/$multihash"
  if test -n "$success"; then
    finish
  fi

  tryDownload "http://127.0.0.1:8080/ipfs/$multihash"
  if test -n "$success"; then
    finish
  fi
fi

for url in $urls; do
  tryDownload "$url"
  if test -n "$success"; then
    finish
  fi
done

# We only ever want to access the official gateway as a last resort as it can be slow
if [ -n "$multihash" ]; then
  tryDownload "https://gateway.ipfs.io/ipfs/$multihash"
  if test -n "$success"; then
    finish
  fi
fi

# Restore globbing settings
set +o noglob


echo "error: cannot download $name from any mirror"
exit 1
