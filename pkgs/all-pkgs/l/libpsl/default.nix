{ stdenv
, fetchurl
, lib
, python3

, libidn2
, libunistring
}:

let
  version = "0.21.0";
in
stdenv.mkDerivation rec {
  name = "libpsl-${version}";

  src = fetchurl {
    url = "https://github.com/rockdaboot/libpsl/releases/download/${name}/"
      + "${name}.tar.gz";
    sha256 = "41bd1c75a375b85c337b59783f5deb93dbb443fb0a52d257f403df7bd653ee12";
  };

  nativeBuildInputs = [
    python3
  ];

  buildInputs = [
    libidn2
    libunistring
  ];

  postPatch = ''
    patchShebangs src/psl-make-dafsa
  '';

  configureFlags = [
    "--disable-man"
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
