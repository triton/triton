{ stdenv
, fetchurl
, python2Packages

, icu
}:

let
  version = "0.17.0";
in
stdenv.mkDerivation rec {
  name = "libpsl-${version}";

  src = fetchurl {
    url = "https://github.com/rockdaboot/libpsl/releases/download/${name}/${name}.tar.gz";
    sha256 = "025729d6a26ffd53cb54b4d86196f62c01d1813a4360c627546c6eb60ce3dd4b";
  };

  nativeBuildInputs = [
    python2Packages.python
  ];

  buildInputs = [
    icu
  ];

  postPatch = ''
    patchShebangs src/psl-make-dafsa
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
