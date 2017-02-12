{ stdenv
, fetchurl

, lzip
}:

stdenv.mkDerivation rec {
  name = "ddrescue-1.22";

  src = fetchurl {
    url = "mirror://gnu/ddrescue/${name}.tar.lz";
    hashOutput = false;
    sha256 = "09857b2e8074813ac19da5d262890f722e5f7900e521a4c60354cef95eea10a7";
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
