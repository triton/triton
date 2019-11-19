{ stdenv
, fetchurl
}:

let
  version = "3.3";
in
stdenv.mkDerivation rec {
  name = "libffi-${version}";

  src = fetchurl {
    urls = [
      "https://github.com/libffi/libffi/releases/download/v${version}/${name}.tar.gz"
      "mirror://sourceware/libffi/${name}.tar.gz"
    ];
    sha256 = "65affdfc67fbb865f39c7e5df2a071c0beb17206ebfb0a9ecb18a18f63f6b263";
  };

  postInstall = ''
    mkdir -p "$lib"/lib
    mv "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  postFixup = ''
    rm -rv "$dev"/share
  '';

  outputs = [
    "dev"
    "lib"
    "man"
  ];

  meta = with stdenv.lib; {
    description = "A foreign function call interface library";
    homepage = http://sourceware.org/libffi/;
    # See http://github.com/atgreen/libffi/blob/master/LICENSE .
    license = licenses.free;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
