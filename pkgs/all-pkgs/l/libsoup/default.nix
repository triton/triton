{ stdenv
, fetchurl
, gettext
, lib
, meson
, ninja

, glib
, glib-networking
, gobject-introspection
, kerberos
, libpsl
, libxml2
, sqlite
, vala

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt;

  sources = {
    "2.64" = {
      version = "2.64.2";
      sha256 = "75ddc194a5b1d6f25033bb9d355f04bfe5c03e0e1c71ed0774104457b3a786c6";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "libsoup-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libsoup/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    meson
    ninja
    vala
  ];

  buildInputs = [
    glib
    gobject-introspection
    kerberos
    libpsl
    libxml2
    sqlite
  ];

  postPatch = ''
    patchShebangs ./libsoup/
  '';

  mesonFlags = [
    #"-Dkrb5_config=/path"
    "-Dtls_check=false"  # glib-networking is only a runtime dependency.
    "-Dtests=false"
  ];

  setVapidirInstallFlag = false;

  postInstall = "rm -rvf $out/share/gtk-doc";

  passthru = {
    propagatedUserEnvPackages = [
      glib-networking
    ];

    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Url = "https://download.gnome.org/sources/libsoup/${channel}/"
          + "${name}.sha256sum";
      };
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "An HTTP library implementation in C";
    homepage = https://wiki.gnome.org/Projects/libsoup;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
