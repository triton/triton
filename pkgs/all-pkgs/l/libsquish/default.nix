{ stdenv
, fetchurl
, lib
}:

let
  version = "1.15";
in
stdenv.mkDerivation rec {
  name = "libsquish-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/libsquish/${name}.tgz";
    sha256 = "628796eeba608866183a61d080d46967c9dda6723bc0a3ec52324c85d2147269";
  };

  preUnpack = ''
    mkdir -p src
    cd src
  '';

  srcRoot = ".";

  postPatch = ''
    grep -q '\-llibsquish' libsquish.pc.in
    sed -i 's,-llibsquish,-lsquish,' libsquish.pc.in
  '';

  makeFlags = [
    "USE_OPENMP=1"
    "USE_SHARED=1"
    "USE_SSE=1"
  ];

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  preInstall = ''
    installFlagsArray+=("INSTALL_DIR=$out")
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
