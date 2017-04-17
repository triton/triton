{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation {
  name = "mujs-2017-04-04";

  src = fetchFromGitHub {
    version = 2;
    owner = "ccxvii";
    repo = "mujs";
    rev = "aa18ef32a67e03aea52890628ce530f73fe0564c";
    sha256 = "239b6a1a863817f0b933d605f077a61eace56c8f9c1c2ee5d079c5606ee7ef3c";
  };

  preInstall = ''
    installFlagsArray+=("prefix=$out")
  '';

  meta = with stdenv.lib; {
    license = licenses.agpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
