{ stdenv
, fetchTritonPatch
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "mp4v2-2.0.0";

  src = fetchurl {
    name = "${name}.tar.bz2";  # Dead project
    multihash = "QmUqS6HpKpUxXm7Pun24MAewxdLT6RGjt4siDvzJTf7nbV";
    sha256 = "0319b9a60b667cf10ee0ec7505eb7bdc0a2e21ca7a93db96ec5bd758e3428338";
  };

  patches = [
    (fetchTritonPatch {
      rev = "6c33588ec6ae219d94af90f4a89b1b4be3dd3551";
      file = "m/mp4v2/gcc7.patch";
      sha256 = "2e5c5007d41c565d8ba42aa0b17508da59eab1a91d342650ac68acb1df5930a1";
    })
  ];

  meta = with lib; {
    description = "Functions for accessing ISO-IEC:14496-1:2001 MPEG-4 standard";
    homepage = https://code.google.com/archive/p/mp4v2/;
    license = licenses.mpl11;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
