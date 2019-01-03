{ stdenv
, fetchurl

, type ? "full"
}:

let
  inherit (stdenv.lib)
    optionalString;
in
stdenv.mkDerivation rec {
  name = "pkgconf-1.5.4";

  src = fetchurl {
    url = "https://distfiles.dereferenced.org/pkgconf/${name}.tar.xz";
    multihash = "QmXuakgijHTF2CYiAXCaUv7uaWtnNfpUy7daCWgDQmg6U6";
    sha256 = "9c5864a4e08428ef52f05a41c948529555458dec6d283b50f8b7d32463c54664";
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
  '' + optionalString (type != "full") ''
    rm -r "$out"/share/{doc,man}
  '';

  allowedReferences = [
    "out"
    stdenv.cc.libc
    stdenv.cc.cc
  ];

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
