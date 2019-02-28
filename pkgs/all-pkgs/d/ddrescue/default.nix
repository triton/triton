{ stdenv
, fetchurl

, lzip
}:

stdenv.mkDerivation rec {
  name = "ddrescue-1.24";

  src = fetchurl {
    url = "mirror://gnu/ddrescue/${name}.tar.lz";
    hashOutput = false;
    sha256 = "4b5d3feede70e3657ca6b3c7844f23131851cbb6af0cecc9721500f7d7021087";
  };

  nativeBuildInputs = [
    lzip
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprint = "1D41 C14B 272A 2219 A739  FA4F 8FE9 9503 132D 7742";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "GNU ddrescue, a data recovery tool";
    homepage = http://www.gnu.org/software/ddrescue/ddrescue.html;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
