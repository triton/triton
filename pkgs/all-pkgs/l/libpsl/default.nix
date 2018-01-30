{ stdenv
, fetchurl
, lib
, python2

, icu
, libidn2
, libunistring
}:

let
  version = "0.19.1";
in
stdenv.mkDerivation rec {
  name = "libpsl-${version}";

  src = fetchurl {
    url = "https://github.com/rockdaboot/libpsl/releases/download/${name}/${name}.tar.gz";
    sha256 = "735146b51bbd3dcb6b0f87819c64bf3115f7fb9fa2e3a7fe9966e3346a8abc79";
  };

  nativeBuildInputs = [
    python2
  ];

  buildInputs = [
    icu
    libidn2
    libunistring
  ];

  postPatch = ''
    patchShebangs src/psl-make-dafsa
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
