{ stdenv
, fetchurl
, lzip
}:

stdenv.mkDerivation rec {
  name = "ed-1.14.1";

  src = fetchurl {
    url = "mirror://gnu/ed/${name}.tar.lz";
    hashOutput = false;
    sha256 = "ffb97eb8f2a2b5a71a9b97e3872adce953aa1b8958e04c5b7bf11d556f32552a";
  };

  nativeBuildInputs = [
    lzip
  ];

  doCheck = true;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "1D41 C14B 272A 2219 A739  FA4F 8FE9 9503 132D 7742";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "An implementation of the standard Unix editor";
    license = licenses.gpl3Plus;
    homepage = http://www.gnu.org/software/ed/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
