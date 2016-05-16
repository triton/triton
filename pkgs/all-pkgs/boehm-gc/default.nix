{ stdenv
, fetchurl

, libatomic_ops
}:

let
  version = "7.4.2";
in
stdenv.mkDerivation rec {
  name = "boehm-gc-${version}";

  src = fetchurl {
    url = "http://www.hboehm.info/gc/gc_source/gc-${version}.tar.gz";
    sha256 = "18mg28rr6kwr5clc65k4l4hkyy4kd16amx831sjf8q2lqkbhlck3";
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
