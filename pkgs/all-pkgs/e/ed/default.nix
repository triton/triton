{ stdenv
, fetchurl
, lzip
}:

stdenv.mkDerivation rec {
  name = "ed-1.14.2";

  src = fetchurl {
    url = "mirror://gnu/ed/${name}.tar.lz";
    hashOutput = false;
    sha256 = "f57962ba930d70d02fc71d6be5c5f2346b16992a455ab9c43be7061dec9810db";
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
