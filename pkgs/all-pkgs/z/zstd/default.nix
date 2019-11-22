{ stdenv
, cmake
, fetchurl
, lib

, version
}:

let
  sha256s = {
    "1.4.4" = "59ef70ebb757ffe74a7b3fe9c305e2ba3350021a918d168a046c6300aeea9315";
  };
in
stdenv.mkDerivation rec {
  name = "zstd-${version}";

  src = fetchurl {
    url = "https://github.com/facebook/zstd/releases/download/v${version}/${name}.tar.gz";
    sha256 = sha256s."${version}";
  };

  makeFlags = [
    "PREFIX=${placeholder "bin"}"
  ];

  postInstall = ''
    mkdir -p "$dev"
    mv "$bin"/{include,lib} "$dev"

    mkdir -p "$lib"/lib
    mv -v "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  postFixup = ''
    rm -rv "$bin"/share
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
    "man"
  ];

  meta = with lib; {
    description = "Fast real-time lossless compression algorithm";
    homepage = http://www.zstd.net/;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
