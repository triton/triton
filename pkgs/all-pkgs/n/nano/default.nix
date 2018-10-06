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
  version = "${channel}.1";
in
stdenv.mkDerivation rec {
  name = "nano-${version}";

  src = fetchurl {
    urls = [
      "https://www.nano-editor.org/dist/v${channel}/${name}.tar.xz"
      "mirror://gnu/nano/${name}.tar.xz"
    ];
    hashOutput = false;
    sha256 = "14c02ca40a5bc61c580ce2f9cb7f9fc72d5ccc9da17ad044f78f6fb3fdb7719e";
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
