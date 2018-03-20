{ stdenv
, fetchurl
, lib

, cairomm
, glibmm
, libpng
, pango

, channel
}:

let
  sources = {
    "2.40" = {
      version = "2.40.1";
      sha256 = "9762ee2a2d5781be6797448d4dd2383ce14907159b30bc12bf6b08e7227be3af";
    };
  };
  source = sources."${channel}";
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

  # XXX: keep in sync with cairo lib name
  postPatch = ''
    sed -i configure \
      -e 's/cairomm-1.0/cairomm-1.16/g'
  '';

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

  meta = with lib; {
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
