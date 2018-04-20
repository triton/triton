{ stdenv
, fetchurl
, libpng
}:

stdenv.mkDerivation rec {
  name = "qrencode-4.0.0";

  src = fetchurl {
    url = "https://fukuchi.org/works/qrencode/${name}.tar.bz2";
    multihash = "QmdntiBk9DrBpTGnCLgMnBpi7Q2ZjVqASuoKSVU9TfaSek";
    sha256 = "c90035e16921117d4086a7fdee65aab85be32beb4a376f6b664b8a425d327d0b";
  };

  buildInputs = [
    libpng
  ];

  meta = with stdenv.lib; {
    homepage = https://fukuchi.org/works/qrencode/;
    description = "QR code encoder";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
