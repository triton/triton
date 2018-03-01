{ stdenv
, fetchurl
, lib
, perl
}:

let
  version = "1.9.3";
in
stdenv.mkDerivation rec {
  name = "libbson-${version}";

  src = fetchurl {
    url = "https://github.com/mongodb/libbson/releases/download"
      + "/${version}/${name}.tar.gz";
    sha256 = "244e786c746fe6326433b1a6fcaadbdedc0da3d11c7b3168f0afa468f310e5f1";
  };

  nativeBuildInputs = [
    perl
  ];

  configureFlags = [
    "--disable-examples"
    "--disable-tests"
  ];

  # Builders don't respect the nested include dir
  postInstall = ''
    incdir="$(echo "$out"/include/*)"
    mv "$incdir"/* "$out/include"
    rmdir "$incdir"
    ln -sv . "$incdir"
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
