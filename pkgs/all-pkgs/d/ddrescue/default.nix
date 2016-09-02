{ stdenv
, fetchurl

, lzip
}:

stdenv.mkDerivation rec {
  name = "ddrescue-1.21";

  src = fetchurl {
    url = "mirror://gnu/ddrescue/${name}.tar.lz";
    hashOutput = false;
    sha256 = "f09e4eb6a209cbd0fe8ee6db2d558238cdc969afa1d94150f263402ac882e1ac";
  };

  nativeBuildInputs = [
    lzip
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "1D41 C14B 272A 2219 A739  FA4F 8FE9 9503 132D 7742";
      inherit (src) urls outputHash outputHashAlgo;
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
