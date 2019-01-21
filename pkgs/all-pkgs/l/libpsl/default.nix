{ stdenv
, fetchurl
, lib
, python2

, libidn2
, libunistring
}:

let
  version = "0.20.2";
in
stdenv.mkDerivation rec {
  name = "libpsl-${version}";

  src = fetchurl {
    url = "https://github.com/rockdaboot/libpsl/releases/download/${name}/"
      + "${name}.tar.gz";
    sha256 = "f8fd0aeb66252dfcc638f14d9be1e2362fdaf2ca86bde0444ff4d5cc961b560f";
  };

  nativeBuildInputs = [
    python2
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
