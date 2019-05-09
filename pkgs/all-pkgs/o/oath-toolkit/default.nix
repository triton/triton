{ stdenv
, fetchTritonPatch
, fetchurl
, lib

, libxml2
, pam
}:

let
  version = "2.6.2";
in
stdenv.mkDerivation rec {
  name = "oath-toolkit-${version}";

  src = fetchurl {
    url = "mirror://savannah/oath-toolkit/${name}.tar.gz";
    hashOutput = false;
    sha256 = "b03446fa4b549af5ebe4d35d7aba51163442d255660558cd861ebce536824aa0";
  };

  patches = [
    (fetchTritonPatch {
      rev = "894813c580b1671fb04d3edb2b2f641e28532dac";
      file = "o/oath-toolkit/fseeko.patch";
      sha256 = "b93dc7bafe32a3477127e55b1c470063660b1f5c3f25622ea581b41502783020";
    })
  ];

  buildInputs = [
    libxml2
    pam
  ];

  configureFlags = [
    "--disable-xmltest"
  ];

  passthru = {
    inherit version;
    srcVerification = fetchurl rec {
      failEarly = true;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprint = "9AA9 BDB1 1BB1 B99A 2128  5A33 0664 A769 5426 5E8C";
      };
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
    };
  };

  meta = with lib; {
    homepage = "http://www.nongnu.org/lzip/lzip.html";
    description = "a lossless data compressor based on the LZMA algorithm";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
