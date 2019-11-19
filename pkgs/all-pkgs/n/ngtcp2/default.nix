{ stdenv
, autoconf
, automake
, fetchFromGitHub
, lib
, libtool

, openssl
}:

let
  date = "2019-11-13";
  rev = "0eb076940fe7a0d5a2f90d9fa7336b9b95f285f5";
in
stdenv.mkDerivation {
  name = "ngtcp2-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "ngtcp2";
    repo = "ngtcp2";
    inherit rev;
    sha256 = "88fb53e5a3ef88bdc2e77208f62d876ee5d5919d911476b645cab62dcbffec43";
  };

  preConfigure = ''
    autoreconf -v -f -i
  '';

  nativeBuildInputs = [
    autoconf.bin
    automake.bin
    libtool.bin
  ];

  buildInputs = [
    # Requires out of tree support right now
    #openssl
  ];

  postInstall = ''
    mkdir -p "$lib"/lib
    mv "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  outputs = [
    "dev"
    "lib"
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux ++
      x86_64-linux ++
      powerpc64le-linux;
  };
}
