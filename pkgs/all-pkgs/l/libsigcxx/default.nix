{ stdenv
, fetchurl
, gnum4
}:

stdenv.mkDerivation rec {
  name = "libsigc++-2.8.0";

  src = fetchurl {
    url = "mirror://gnome/sources/libsigc++/2.8/${name}.tar.xz";
    sha256 = "774980d027c52947cb9ee4fac6ffe2ca60cc2f753068a89dfd281c83dbff9651";
  };

  nativeBuildInputs = [
    gnum4
  ];

  # This is to fix c++11 comaptability with other applications
  setupHook = ./setup-hook.sh;

  meta = with stdenv.lib; {
    homepage = http://libsigc.sourceforge.net/;
    description = "A typesafe callback system for standard C++";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
