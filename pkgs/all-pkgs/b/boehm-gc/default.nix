{ stdenv
, fetchurl
, lib

, libatomic_ops
}:

let
  version = "8.0.0";
in
stdenv.mkDerivation rec {
  name = "boehm-gc-${version}";

  src = fetchurl {
    url = "https://github.com/ivmai/bdwgc/releases/download/v${version}/gc-${version}.tar.gz";
    sha256 = "8f23f9a20883d00af2bff122249807e645bdf386de0de8cbd6cce3e0c6968f04";
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
