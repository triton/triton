{ stdenv
, fetchurl

, zlib
}:

let
  version = "1.13";
in
stdenv.mkDerivation rec {
  name = "potrace-${version}";

  src = fetchurl {
    url = "http://potrace.sourceforge.net/download/${version}/potrace-${version}.tar.gz";
    sha256 = "115p2vgyq7p2mf4nidk2x3aa341nvv2v8ml056vbji36df5l6lk2";
  };

  configureFlags = [
    "--with-libpotrace"
  ];

  buildInputs = [
    zlib
  ];

  meta = with stdenv.lib; {
    homepage = http://potrace.sourceforge.net/;
    description = "A tool for tracing a bitmap, which means, transforming a bitmap into a smooth, scalable image";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
