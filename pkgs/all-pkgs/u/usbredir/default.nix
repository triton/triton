{ stdenv
, fetchurl

, libusb
}:

stdenv.mkDerivation rec {
  name = "usbredir-0.7";

  src = fetchurl {
    url = "https://www.spice-space.org/download/usbredir/${name}.tar.bz2";
    multihash = "QmNMnW9zA1xLKLMYPw3msDwTHeo555WBKVJjtNqBmA8Man";
    sha256 = "0a63a0712b5dc62be9cca44f97270fea5d1ec1fe7dde0c11dc74a01c8e2006aa";
  };

  buildInputs = [
    libusb
  ];

  postPatch = ''
    sed -i 's, -Werror,,' configure
  '';

  meta = with stdenv.lib; {
    description = "Protocol headers for the SPICE protocol";
    homepage = http://www.spice-space.org;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
