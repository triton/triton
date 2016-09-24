{ stdenv
, fetchurl

, cairomm
, glibmm
, libpng
, pango

, channel
}:

let
  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "pangomm-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/pangomm/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  buildInputs = [
    cairomm
    glibmm
    libpng
    pango
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-deprecated-api"
    "--disable-documentation"
    "--enable-warnings"
    "--without-libstdc-doc"
    "--without-libsigc-doc"
    "--without-glibmm-doc"
    "--without-cairomm-doc"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/pangomm/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
    description = "C++ interface to the Pango text rendering library";
    homepage = http://www.pango.org/;
    license = with licenses; [
      lgpl2
      lgpl21
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
