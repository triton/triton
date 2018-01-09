{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "pkgconf-1.4.0";

  src = fetchurl {
    url = "https://distfiles.dereferenced.org/pkgconf/${name}.tar.xz";
    multihash = "QmckjKaZQFrrWMrCQZSVbCGdzGXq7nEQaKjLLxGNu8uAs7";
    sha256 = "1d112ff35dad516ffbfbdb013df3a035140618fe7632ec44ffa894a9c713301b";
  };

  postInstall = ''
    # The install is broken and is missing libpkgconfig/config.h
    cp -v libpkgconf/config.h "$out"/include/pkgconf

    # The header files expect themselves to be in libpkgconf
    # however they are installed to pkgconf
    test -d "$out"/include/pkgconf
    ln -sv pkgconf "$out"/include/libpkgconf

    # We want compatability with pkg-config
    ln -sv pkgconf "$out"/bin/pkg-config
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
