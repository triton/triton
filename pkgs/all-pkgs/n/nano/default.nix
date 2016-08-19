{ stdenv
, fetchurl
, gettext

, ncurses
}:

let
  major = "2.6";
  patch = "3";

  version = "${major}.${patch}";
in
stdenv.mkDerivation rec {
  name = "nano-${version}";

  src = fetchurl {
    urls = [
      "https://www.nano-editor.org/dist/v${major}/${name}.tar.gz"
      "mirror://gnu/nano/${name}.tar.gz"
    ];
    allowHashOutput = false;
    sha256 = "4f4054e12f2181c8e436163e931a0a565612242ff9e566c4d1adeda0f91fd503";
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
