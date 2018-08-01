{ stdenv
, fetchurl
, gettext
, meson
, ninja
, python3
, vala

, glib

, channel
}:

let
  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "dconf-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/dconf/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    meson
    ninja
    python3
    vala
  ];

  buildInputs = [
    glib
  ];

  postPatch = ''
    chmod +x meson_post_install.py
    patchShebangs meson_post_install.py
  '';

  setVapidirInstallFlag = false;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/dconf/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
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
