{ stdenv
, fetchurl
, gnum4

, channel
}:

let
  source = (import ./sources.nix { })."${channel}";
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

  # This is to fix c++11 comaptability with other applications
  setupHook = ./setup-hook.sh;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/libsigc++/${channel}/"
        + "${name}.sha256sum";
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
