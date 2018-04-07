{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "pkgconf-1.4.2";

  src = fetchurl {
    url = "https://distfiles.dereferenced.org/pkgconf/${name}.tar.xz";
    multihash = "Qmc2pkAWeoa1DWZNMT8jSB44R8Lq7yxG9u1rCHbns2VLT4";
    sha256 = "bab39371d4ab972be1d539a8b10b6cc21f8eafc97f617102e667e82bd32eb234";
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
