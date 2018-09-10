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
  channel = "3";
  version = "${channel}.0";
in
stdenv.mkDerivation rec {
  name = "nano-${version}";

  src = fetchurl {
    urls = [
      "https://www.nano-editor.org/dist/v${channel}/${name}.tar.xz"
      "mirror://gnu/nano/${name}.tar.xz"
    ];
    hashOutput = false;
    sha256 = "e0a5bca354514e64762c987c200a8758b05e7bcced3b00b3e48ea0a2d383c8a0";
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
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = [
          "https://www.nano-editor.org/dist/v${channel}/${name}.tar.xz.asc"
          "mirror://gnu/nano/${name}.tar.xz.sig"
        ];
        pgpKeyFingerprint = "BFD0 0906 1E53 5052 AD0D  F215 0D28 D4D2 A0AC E884";
      };
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
