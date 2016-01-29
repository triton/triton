{ stdenv, fetchurl, autoreconfHook }:

stdenv.mkDerivation rec {
  name = "pkgconf-2015-12-08";

  src = fetchurl {
    url = "https://github.com/pkgconf/pkgconf/archive/ceb7232190e4a6942a3a4ead5a59fa6024e62e0b.tar.gz";
    sha256 = "0laii4m06l0h5n48wcccmhyab4awr7mgyn0npb3lcmxn13myc22p";
  };

  nativeBuildInputs = [ autoreconfHook ];

  postInstall = ''
    # The install is broken and is missing libpkgconfig/config.h
    cp libpkgconf/config.h $out/include/pkgconf

    # The header files expect themselves to be in libpkgconf
    # however they are installed to pkgconf
    ln -s pkgconf $out/include/libpkgconf

    # We want compatability with pkg-config
    ln -s pkgconf $out/bin/pkg-config
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/pkgconf/pkgconf";
    description = "a tool and framework (libpkgconf) which provides compiler and linker configuration for development frameworks";
    platforms = platforms.all;
  };
}
