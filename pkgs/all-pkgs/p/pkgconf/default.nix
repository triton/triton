{ stdenv
, fetchurl

, type ? "full"
}:

let
  inherit (stdenv.lib)
    optionalString;
in
stdenv.mkDerivation rec {
  name = "pkgconf-1.6.1";

  src = fetchurl {
    url = "https://distfiles.dereferenced.org/pkgconf/${name}.tar.xz";
    multihash = "QmeRLRYaTsvc1oN8EgoTECe2wjSxAdsAkyh9aus4KP5pNu";
    sha256 = "22b9ee38438901f9d60f180e5182821180854fa738fd071f593ea26a81da208c";
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
  ] ++ stdenv.cc.runtimeLibcLibs;

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
