{ stdenv, fetchurl, pkgconfig, gnum4 }:

stdenv.mkDerivation rec {
  name = "libsigc++-2.6.2";

  src = fetchurl {
    url = "mirror://gnome/sources/libsigc++/2.6/${name}.tar.xz";
    sha256 = "0ds4wlys149gi320xiy452dr0mq6r94r03sp2wn7kpii9h9ygb7x";
  };

  nativeBuildInputs = [ pkgconfig gnum4 ];

  doCheck = true;

  # This is to fix c++11 comaptability with other applications
  setupHook = ./setup-hook.sh;

  meta = with stdenv.lib; {
    homepage = http://libsigc.sourceforge.net/;
    description = "A typesafe callback system for standard C++";
    platforms = platforms.all;
  };
}
