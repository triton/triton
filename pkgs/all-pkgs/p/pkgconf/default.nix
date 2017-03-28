{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "pkgconf-1.3.3";

  src = fetchurl {
    url = "https://distfiles.dereferenced.org/pkgconf/${name}.tar.xz";
    multihash = "Qmc9uqqte6PCgeiDpmP388Ec8eYWwP6kJ2PGCd2WJjChD8";
    sha256 = "e7ca3c12d447dc29bbae5fc9302514385735b71f2771e2f37d045929e7008b7a";
  };

  postInstall = ''
    # The install is broken and is missing libpkgconfig/config.h
    cp -v libpkgconf/config.h $out/include/pkgconf

    # The header files expect themselves to be in libpkgconf
    # however they are installed to pkgconf
    ln -sv pkgconf $out/include/libpkgconf

    # We want compatability with pkg-config
    ln -sv pkgconf $out/bin/pkg-config
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/pkgconf/pkgconf";
    description = "a tool and framework (libpkgconf) which provides compiler and linker configuration for development frameworks";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
