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
  version = "${channel}.8";
in
stdenv.mkDerivation rec {
  name = "nano-${version}";

  src = fetchurl {
    urls = [
      "https://www.nano-editor.org/dist/v${channel}/${name}.tar.xz"
      "mirror://gnu/nano/${name}.tar.xz"
    ];
    hashOutput = false;
    sha256 = "c2deac31ba4d3fd27a42fafcc47ccf499296cc69a422bbecab63f2933ea85488";
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
