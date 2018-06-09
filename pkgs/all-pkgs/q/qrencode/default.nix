{ stdenv
, fetchurl
, libpng
}:

stdenv.mkDerivation rec {
  name = "qrencode-4.0.2";

  src = fetchurl {
    url = "https://fukuchi.org/works/qrencode/${name}.tar.bz2";
    multihash = "QmRFJHZN5xzbJUNt3Uigj5epDQiNRhBSrSKJ7Vt8rM3SuP";
    sha256 = "c9cb278d3b28dcc36b8d09e8cad51c0eca754eb004cb0247d4703cb4472b58b4";
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
