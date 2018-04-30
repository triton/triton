{ stdenv
, fetchurl
, gettext
, groff
, lib

, file
, ncurses
, zlib
}:

let
  channel = "2.9";
  version = "${channel}.6";
in
stdenv.mkDerivation rec {
  name = "nano-${version}";

  src = fetchurl {
    urls = [
      "https://www.nano-editor.org/dist/v${channel}/${name}.tar.xz"
      "mirror://gnu/nano/${name}.tar.xz"
    ];
    hashOutput = false;
    sha256 = "a373507ebb4e9307a8202fbc19b5d29718025c8ec773669349211c362545d4c6";
  };

  nativeBuildInputs = [
    gettext
    groff
  ];

  buildInputs = [
    file
    ncurses
    zlib
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
      pgpKeyFingerprint = "BFD0 0906 1E53 5052 AD0D  F215 0D28 D4D2 A0AC E884";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    description = "A small, user-friendly console text editor";
    homepage = http://www.nano-editor.org/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
