{ stdenv
, docbook-xsl
, fetchurl
, gettext
, lib
, libxslt
, meson
, ninja
, python3
, vala

, dbus-dummy
, glib

, channel
}:

let
  sources = {
    "0.30" = {
      version = "0.30.1";
      sha256 = "549a3a7cc3881318107dc48a7b02ee8f88c9127acaf2d47f7724f78a8f6d02b7";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "dconf-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/dconf/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    docbook-xsl
    libxslt
    meson
    ninja
    python3
    vala
  ];

  buildInputs = [
    dbus-dummy
    glib
  ];

  postPatch = ''
    chmod +x meson_post_install.py
    patchShebangs meson_post_install.py
  '';

  mesonFlags = [
    "-Dbash_completion=false"
  ];

  setVapidirInstallFlag = false;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Url = "https://download.gnome.org/sources/dconf/${channel}/"
          + "${name}.sha256sum";
      };
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Simple low-level configuration system";
    homepage = https://wiki.gnome.org/dconf;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
