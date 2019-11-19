{ stdenv
, cc
, fetchurl

, type ? "full"
}:

let
  inherit (stdenv.lib)
    optionals;
in
stdenv.mkDerivation rec {
  name = "pkgconf-1.6.1";

  src = fetchurl {
    url = "https://distfiles.dereferenced.org/pkgconf/${name}.tar.xz";
    multihash = "QmeRLRYaTsvc1oN8EgoTECe2wjSxAdsAkyh9aus4KP5pNu";
    sha256 = "22b9ee38438901f9d60f180e5182821180854fa738fd071f593ea26a81da208c";
  };

  nativeBuildInputs = [
    cc
  ];

  configureFlags = [
    "--with-personality-dir=/no-such-path"
    "--with-pkg-config-dir=/no-such-path"
    "--with-system-libdir=/no-such-path"
    "--with-system-includedir=/no-such-path"
  ];

  postInstall = ''
    # Move bin files
    mkdir -p "$bin"/share
    mv -v "$dev"/bin "$bin"
    mv -v "$dev"/share/aclocal "$bin"/share

    # Move shared libs
    mkdir -p "$lib"/lib
    mv -v "$dev"/lib*/*.so* "$lib"/lib

    # The header files expect themselves to be in libpkgconf
    # however they are installed to pkgconf
    test -d "$dev"/include/pkgconf
    ln -sv pkgconf/libpkgconf "$dev"/include

    # We want compatability with pkg-config
    ln -sv pkgconf "$bin"/bin/pkg-config
  '';

  postFixup = ''
    ln -sv "$lib"/lib/* "$dev"/lib
    rm -rv "$dev"/share
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
  ] ++ optionals (type == "full") [
    "man"
  ];

  meta = with stdenv.lib; {
    homepage = "https://github.com/pkgconf/pkgconf";
    description = "a tool and framework (libpkgconf) which provides compiler and linker configuration for development frameworks";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux ++
      x86_64-linux ++
      powerpc64le-linux;
  };
}
