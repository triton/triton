{ stdenv
, fetchurl
, lib

, libatomic_ops
}:

let
  version = "8.0.2";
in
stdenv.mkDerivation rec {
  name = "boehm-gc-${version}";

  src = fetchurl {
    url = "https://github.com/ivmai/bdwgc/releases/download/v${version}/gc-${version}.tar.gz";
    sha256 = "4e8ca4b5b72a3a27971daefaa9b621f0a716695b23baa40b7eac78de2eeb51cb";
  };

  buildInputs = [
    libatomic_ops
  ];

  configureFlags = [
    "--enable-cplusplus"
    "--enable-large-config"
    "--disable-docs"
  ];

  meta = with lib; {
    description = "The Boehm-Demers-Weiser conservative garbage collector for C and C++";
    homepage = http://hboehm.info/gc/;
    license = licenses.free;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
