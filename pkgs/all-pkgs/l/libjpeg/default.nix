{ stdenv
, fetchurl
}:

let
  version = "9c";
in
stdenv.mkDerivation rec {
  name = "libjpeg-${version}";

  src = fetchurl {
    url = "https://www.ijg.org/files/jpegsrc.v${version}.tar.gz";
    multihash = "QmPmVAq9Znb4htYfD7zBQWQ17ntsJwNXigush3cJN1jGyg";
    sha256 = "650250979303a649e21f87b5ccd02672af1ea6954b911342ea491f351ceb7122";
  };

  passthru = {
    type = "normal";
  };

  meta = with stdenv.lib; {
    description = "A library that implements the JPEG image file format";
    homepage = http://www.ijg.org/;
    license = licenses.ijg;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
