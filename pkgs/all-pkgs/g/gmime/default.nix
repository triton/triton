{ stdenv
, fetchurl
, lib
, vala

, glib
, gobject-introspection
, libgpg-error
, libidn
, zlib
}:

let
  channel = "3.2";
  version = "${channel}.3";
in
stdenv.mkDerivation rec {
  name = "gmime-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gmime/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "6a0875eeb552ab447dd54853a68ced62217d863631048737dd97eaa2713e7311";
  };

  nativeBuildInputs = [
    vala
  ];

  buildInputs = [
    glib
    gobject-introspection
    libgpg-error
    libidn
    zlib
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-crypto"
    "--enable-introspection"
    "--enable-vala"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Urls =
          map (u: lib.replaceStrings ["tar.xz"] ["sha256sum"] u) src.urls;
      };
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "A C/C++ library for manipulating MIME messages";
    homepage = http://spruce.sourceforge.net/gmime/;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
