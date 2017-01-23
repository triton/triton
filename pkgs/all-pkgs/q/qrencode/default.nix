{ stdenv
, fetchurl
, libpng
}:

stdenv.mkDerivation rec {
  name = "qrencode-3.4.4";

  src = fetchurl {
    url = "https://fukuchi.org/works/qrencode/${name}.tar.bz2";
    multihash = "Qma2igUXcx1UPLW2qhsxqx3Xjbi4F6ZaiGRxhb3Ef913cF";
    sha256 = "198zvsfa2y5bb3ccikrhmhd4i43apr3b26dqcf3zkjyv3n5iirgg";
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
