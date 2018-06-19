{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "pkgconf-1.5.1";

  src = fetchurl {
    url = "https://distfiles.dereferenced.org/pkgconf/${name}.tar.xz";
    multihash = "QmfSQ4St6HjvxcbUuSpK8qbUioAh5Gu1FfkSuuSaVeibGf";
    sha256 = "d6877d721f84b59f137da48b237f16e68b598f5afc4f2a04d0a5c9e7e2bf5462";
  };

  configureFlags = [
    "--with-personality-dir=/no-such-path"
    "--with-pkg-config-dir=/no-such-path"
    "--with-system-libdir=/no-such-path"
    "--with-system-includedir=/no-such-path"
  ];

  postInstall = ''
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
