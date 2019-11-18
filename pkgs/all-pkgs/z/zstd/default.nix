{ stdenv
, cmake
, fetchurl
, lib

, version
}:

let
  sha256s = {
    "1.4.3" = "e88ec8d420ff228610b77fba4fbf22b9f8b9d3f223a40ef59c9c075fcdad5767";
  };
in
stdenv.mkDerivation rec {
  name = "zstd-${version}";

  src = fetchurl {
    url = "https://github.com/facebook/zstd/releases/download/v${version}/${name}.tar.gz";
    sha256 = sha256s."${version}";
  };

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$bin"
    )
  '';

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
