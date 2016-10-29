{ stdenv
, fetchurl
, gettext

, ncurses
}:

let
  major = "2.7";
  patch = "1";

  version = "${major}.${patch}";
in
stdenv.mkDerivation rec {
  name = "nano-${version}";

  src = fetchurl {
    urls = [
      "https://www.nano-editor.org/dist/v${major}/${name}.tar.gz"
      "mirror://gnu/nano/${name}.tar.gz"
    ];
    hashOutput = false;
    sha256 = "81547310d3ab7a220426c9c2f2435a372fb43d4b27818f016de25698862ae118";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    ncurses
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--enable-nls"
    "--disable-tiny"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "A7F6 A64A 67DA 09EF 9278  2DD7 9DF4 862A F117 5C5B ";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.nano-editor.org/;
    description = "A small, user-friendly console text editor";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
