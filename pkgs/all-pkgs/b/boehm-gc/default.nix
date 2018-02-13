{ stdenv
, fetchurl
, lib

, libatomic_ops
}:

let
  version = "7.6.4";
in
stdenv.mkDerivation rec {
  name = "boehm-gc-${version}";

  src = fetchurl {
    url = "https://github.com/ivmai/bdwgc/releases/download/v${version}/gc-${version}.tar.gz";
    # We need the multihash because they delete old releases
    multihash = "QmZ2oL3LwQB7FixEAzqZkSRRsdVV4cMFxGfhRY4jhms9Y1";
    sha256 = "b94c1f2535f98354811ee644dccab6e84a0cf73e477ca03fb5a3758fb1fecd1c";
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
