{ stdenv
, fetchurl

, ncurses
}:

stdenv.mkDerivation rec {
  name = "libedit-20180525-3.1";

  src = fetchurl {
    url = "https://thrysoee.dk/editline/${name}.tar.gz";
    multihash = "QmawPtK1fBi59SVtABvSZEbjTtBxUpJECyvvc6o1hrnRxY";
    sha256 = "c41bea8fd140fb57ba67a98ec1d8ae0b8ffa82f4aba9c35a87e5a9499e653116";
  };

  buildInputs = [
    ncurses
  ];

  configureFlags = [
    "--disable-examples"
  ];

  meta = with stdenv.lib; {
    homepage = "https://thrysoee.dk/editline/";
    description = "A port of the NetBSD Editline library (libedit)";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
