{ stdenv
, fetchurl

, libnl
}:

stdenv.mkDerivation rec {
  name = "libibverbs-1.2.1";

  src = fetchurl {
    url = "https://www.openfabrics.org/downloads/verbs/${name}.tar.gz";
    sha256 = "c352a7f24e9a9d30ea74faa35d1b721d78d770506a0c03732e3132b7c85ac330";
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
