{ stdenv
, fetchurl
, lib
, python2

, icu
, libidn2
, libunistring
}:

let
  version = "0.20.0";
in
stdenv.mkDerivation rec {
  name = "libpsl-${version}";

  src = fetchurl {
    url = "https://github.com/rockdaboot/libpsl/releases/download/${name}/${name}.tar.gz";
    sha256 = "27a2547b87689b7a62f8ff807ae4d8240c6f2b2eb8893ca391d686b3aaa95267";
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
