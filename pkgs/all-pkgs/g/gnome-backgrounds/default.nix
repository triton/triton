{ stdenv
, fetchurl
, gettext
, intltool

, channel
}:

let
  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "gnome-backgrounds-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-backgrounds/${channel}/"
      + "${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gnome-backgrounds/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
    description = "A set of backgrounds packaged with the GNOME desktop";
    homepage = https://git.gnome.org/browse/gnome-backgrounds;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
