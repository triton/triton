{ stdenv
, fetchurl
, libpng
}:

stdenv.mkDerivation rec {
  name = "qrencode-3.4.4";

  src = fetchurl {
    url = "${meta.homepage}/${name}.tar.bz2";
    sha256 = "198zvsfa2y5bb3ccikrhmhd4i43apr3b26dqcf3zkjyv3n5iirgg";
  };

  buildInputs = [
    libpng
  ];

  meta = with stdenv.lib; {
    homepage = http://fukuchi.org/works/qrencode/;
    description = "QR code encoder";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
