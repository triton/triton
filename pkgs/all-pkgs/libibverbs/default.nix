{ stdenv
, fetchurl

, libnl
}:

stdenv.mkDerivation rec {
  name = "libibverbs-1.2.0";

  src = fetchurl {
    url = "https://www.openfabrics.org/downloads/verbs/${name}.tar.gz";
    sha256 = "dff6a3126fd19e84d57fb849f1fc43f161699c39fc6a0866e573378339b42ed0";
  };

  buildInputs = [
    libnl
  ];

  meta = with stdenv.lib; {
    homepage = https://www.openfabrics.org/;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
