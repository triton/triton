{ stdenv
, fetchurl
, gnum4

, channel
}:

let
  sources = {
    "2.10" = {
      version = "2.10.0";
      sha256 = "f843d6346260bfcb4426259e314512b99e296e8ca241d771d21ac64f28298d81";
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
