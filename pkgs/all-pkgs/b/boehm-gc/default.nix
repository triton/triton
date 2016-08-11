{ stdenv
, fetchurl

, libatomic_ops
}:

let
  version = "7.6.0";
in
stdenv.mkDerivation rec {
  name = "boehm-gc-${version}";

  src = fetchurl {
    url = "http://www.hboehm.info/gc/gc_source/gc-${version}.tar.gz";
    multihash = "QmV6pGGQW7HvkyAXnE8D8SEwp2B9u75PefYjHBUgYJiU5Z";
    sha256 = "a14a28b1129be90e55cd6f71127ffc5594e1091d5d54131528c24cd0c03b7d90";
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
