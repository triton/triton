{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "pkgconf-1.0.1";

  src = fetchurl {
    url = "https://github.com/pkgconf/pkgconf/releases/download/${name}/"
      + "${name}.tar.xz";
    sha256 = "37db912cf060ed0a3113114515597f3c566d3ab796973c5c408691e20ec1fe20";
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
