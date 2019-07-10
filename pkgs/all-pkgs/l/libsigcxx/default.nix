{ stdenv
, fetchurl
, gnum4

, channel
}:

let
  sources = {
    "2.10" = {
      version = "2.10.2";
      sha256 = "b1ca0253379596f9c19f070c83d362b12dfd39c0a3ea1dd813e8e21c1a097a98";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "libsigc++-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libsigc++/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gnum4
  ];

  # This is to fix c++11 compatability with other applications
  setupHook = ./setup-hook.sh;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Url = "https://download.gnome.org/sources/libsigc++/${channel}/"
          + "${name}.sha256sum";
      };
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
    description = "A typesafe callback system for standard C++";
    homepage = http://libsigc.sourceforge.net/;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
