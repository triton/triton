{ stdenv
, fetchurl
, lib

, libatomic_ops
}:

let
  version = "7.6.6";
in
stdenv.mkDerivation rec {
  name = "boehm-gc-${version}";

  src = fetchurl {
    url = "https://github.com/ivmai/bdwgc/releases/download/v${version}/gc-${version}.tar.gz";
    # We need the multihash because they delete old releases
    multihash = "QmZCCEGDkqYPG3TJU9M5YcmiMgJAeCBYLtqGjrszHSQvXs";
    sha256 = "e968edf8f80d83284dd473e00a5e3377addc2df261ffb7e6dc77c9a34a0039dc";
  };

  buildInputs = [
    libatomic_ops
  ];

  configureFlags = [
    "--enable-cplusplus"
    "--enable-large-config"
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
