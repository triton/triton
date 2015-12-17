{ stdenv, fetchurl, autoreconfHook }:

stdenv.mkDerivation rec {
  name = "pkgconf-2015-12-08";

  src = fetchurl {
    url = "https://github.com/pkgconf/pkgconf/archive/ceb7232190e4a6942a3a4ead5a59fa6024e62e0b.tar.gz";
    sha256 = "0laii4m06l0h5n48wcccmhyab4awr7mgyn0npb3lcmxn13myc22p";
  };

  nativeBuildInputs = [ autoreconfHook ];

  postInstall = ''
    ln -s pkgconf $out/bin/pkg-config
  '';

  setupHook = ../pkgconfig/setup-hook.sh;

  meta = with stdenv.lib; {
    homepage = "https://github.com/pkgconf/pkgconf";
    description = "a tool and framework (libpkgconf) which provides compiler and linker configuration for development frameworks";
    platforms = platforms.all;
  };
}
