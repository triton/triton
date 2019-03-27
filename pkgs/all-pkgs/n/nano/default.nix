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
  channel = "4";
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
    sha256 = "1e2fcfea35784624a7d86785768b772d58bb3995d1aec9176a27a113b1e9bac3";
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
