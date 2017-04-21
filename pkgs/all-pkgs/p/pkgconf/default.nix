{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "pkgconf-1.3.5";

  src = fetchurl {
    url = "https://distfiles.dereferenced.org/pkgconf/${name}.tar.xz";
    multihash = "QmZTseX6TnPVCLbmvdpxdhCSQe7UB7e7gp27eftmYJgLLF";
    sha256 = "886c397b22907209a7483229a8bf473afe151de50527c4b4d04b94fdba0f0c8e";
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
