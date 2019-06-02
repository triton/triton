{ stdenv
, fetchurl
, lib

, libatomic_ops
}:

let
  version = "8.0.4";
in
stdenv.mkDerivation rec {
  name = "boehm-gc-${version}";

  src = fetchurl {
    url = "https://github.com/ivmai/bdwgc/releases/download/v${version}/gc-${version}.tar.gz";
    sha256 = "436a0ddc67b1ac0b0405b61a9675bca9e075c8156f4debd1d06f3a56c7cd289d";
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
