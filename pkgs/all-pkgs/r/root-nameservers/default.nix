{ stdenv
, fetchurl
}:

fetchurl rec {
  name = "root-nameservers-2016-10-20";
  multihash = "QmSFUFrTp1kwRC9UTSyADymSv8gRhHuEX5LhkUWmoceu7t";
  sha256 = "1grymcyzvpl7ag7rbr92yvvwqn8p20fwz4w252i7rq783sky3p05";
  downloadToTemp = true;
  recursiveHash = true;

  postFetch = ''
    if [ "$(openssl ${passthru.srcFile.outputHashAlgo} -r -hex "$downloadedFile" 2>/dev/null | tail -n 1 | awk '{print $1}')" != "${passthru.srcFile.outputHash}" ]; then
      echo "Hash does not match the source file" >&2
      exit 1
    fi
    mkdir -p "$out"/share/dns
    mv "$downloadedFile" "$out"/share/dns/named.root
  '';

  passthru = {
    srcFile = fetchurl rec {
      failEarly = true;
      url = "https://www.internic.net/domain/named.root";
      pgpsigUrl = "${url}.sig";
      pgpKeyFingerprint = "F0CB 1A32 6BDF 3F3E FA3A  01FA 937B B869 E3A2 38C5";
      sha256 = "e3a76ae953ac11e6598e80b14fd8a93bddd7b3a57830fd9ce16fe820fe1df7a2";
    };
  };
  
  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
