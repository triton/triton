{ stdenv
, cmake
, fetchurl
, lib
, ninja
, unzip
}:

stdenv.mkDerivation rec {
  name = "libb64-1.2.1";

  src = fetchurl {
    url = "mirror://sourceforge/libb64/libb64/libb64/${name}.zip";
    sha256 = "20106f0ba95cfd9c35a13c71206643e3fb3e46512df3e2efb2fdbf87116314b2";
  };

  nativeBuildInputs = [
    cmake
    ninja
    unzip
  ];

  postPatch = ''
    ln -sv ${./CMakeLists.txt} CMakeLists.txt
  '';

  meta = with lib; {
    description = "Fast Base64 encoding/decoding routines";
    homepage = http://libb64.sourceforge.net/;
    licenses = licenses.free; # CC-PD
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
