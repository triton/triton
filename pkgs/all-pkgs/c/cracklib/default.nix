{ stdenv
, fetchurl

, zlib
}:

let
  version = "2.9.7";
in
stdenv.mkDerivation rec {
  name = "cracklib-${version}";

  src = fetchurl {
    url = "https://github.com/cracklib/cracklib/releases/download/v${version}/${name}.tar.bz2";
    multihash = "QmRDAr75raDE5hm79292dnmnUMsFrLTFj68qfVYDuWr3Di";
    sha256 = "fe82098509e4d60377b998662facf058dc405864a8947956718857dbb4bc35e6";
  };

  buildInputs = [
    zlib
  ];

  prefix = placeholder "bin";

  preBuild = ''
    makeFlagsArray+=('pkgdatadir=$lib/share/$(PACKAGE)')
  '';

  postInstall = ''
    mkdir -p "$dev"
    mv "$bin"/{include,lib} "$dev"

    mkdir -p "$lib"/lib
    mv -v "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
  ];

  meta = with stdenv.lib; {
    description = "A library for checking the strength of passwords";
    homepage = https://github.com/cracklib/cracklib;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
