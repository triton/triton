{ stdenv
, fetchurl

, libatomic_ops
}:

let
  version = "7.6.2";
in
stdenv.mkDerivation rec {
  name = "boehm-gc-${version}";

  src = fetchurl {
    url = "https://github.com/ivmai/bdwgc/releases/download/v${version}/gc-${version}.tar.gz";
    # We need the multihash because they delete old releases
    multihash = "QmQk6ZAat55XZWmDAekm9yNazs7unB68ocjWUA7VwKqHzE";
    sha256 = "bd112005563d787675163b5afff02c364fc8deb13a99c03f4e80fdf6608ad41e";
  };

  buildInputs = [
    libatomic_ops
  ];

  configureFlags = [
    "--enable-cplusplus"
    "--enable-large-config"
  ];

  meta = with stdenv.lib; {
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
