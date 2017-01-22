{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "pkgconf-1.2.0";

  src = fetchurl {
    url = "https://distfiles.dereferenced.org/pkgconf/${name}.tar.xz";
    multihash = "QmPzgjzdbhexoheiDWPT16SvbxgPhaCdqgHvJ81GtfN8tC";
    sha256 = "7ec3839ed22f9e400fd3e6bf993b69ae74b9c1bf3d407293a7f6786725c2808a";
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
