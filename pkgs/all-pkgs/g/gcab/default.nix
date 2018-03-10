{ stdenv
, fetchurl
, gettext
, intltool
, lib
, meson
, ninja

, glib
, gobject-introspection
, vala
, zlib
}:

let
  channel = "1.1";
  version = "${channel}";
in
stdenv.mkDerivation rec {
  name = "gcab-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gcab/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "192b2272c2adfde43595e5c62388854bca8a404bc796585b638e81774dd62950";
  };

  nativeBuildInputs = [
    gettext
    intltool
    meson
    ninja
    vala
  ];

  buildInputs = [
    glib
    gobject-introspection
    zlib
  ];

  postPatch = /* Remove for >1.1 */ ''
    sed -i meson.build \
      -e 's/git_version =.*/git_version = []/'
  '';

  mesonFlags = [
    "-Ddocs=false"
    "-Dintrospection=true"
    "-Dtest=false"
  ];

  setVapidirInstallFlag = false;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gcab/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Library and tool for Microsoft Cabinet (CAB) files";
    homepage = https://wiki.gnome.org/msitools;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
