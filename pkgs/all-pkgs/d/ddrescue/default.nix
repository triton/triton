{ stdenv
, fetchurl

, lzip
}:

stdenv.mkDerivation rec {
  name = "ddrescue-1.23";

  src = fetchurl {
    url = "mirror://gnu/ddrescue/${name}.tar.lz";
    hashOutput = false;
    sha256 = "a9ae2dd44592bf386c9c156a5dacaeeb901573c9867ada3608f887d401338d8d";
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
