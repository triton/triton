{ stdenv
, fetchurl
, python2Packages

, icu
, libidn2
, libunistring
}:

let
  version = "0.18.0";
in
stdenv.mkDerivation rec {
  name = "libpsl-${version}";

  src = fetchurl {
    url = "https://github.com/rockdaboot/libpsl/releases/download/${name}/${name}.tar.gz";
    sha256 = "91b0f7954709ced5d6ad44d0e2b872675300d834573a569bb516eb46916e3102";
  };

  nativeBuildInputs = [
    python2Packages.python
  ];

  buildInputs = [
    icu
    libidn2
    libunistring
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
