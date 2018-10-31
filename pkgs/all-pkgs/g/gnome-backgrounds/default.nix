{ stdenv
, fetchurl
, gettext
, lib
, meson
, ninja

, channel
}:

let
  sources = {
    "3.30" = {
      version = "3.30.0";
      sha256 = "ece63a2aaf2e9b685721d125b7832fee63749db58743bc147ee92e136896e984";
    };
  };
  source = sources."${channel}";
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
    meson
    ninja
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Url = "https://download.gnome.org/sources/gnome-backgrounds/"
          + "${channel}/${name}.sha256sum";
      };
      failEarly = true;
    };
  };

  meta = with lib; {
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
