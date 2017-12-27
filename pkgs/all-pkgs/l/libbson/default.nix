{ stdenv
, fetchurl
, perl
}:

let
  version = "1.9.0";
in
stdenv.mkDerivation rec {
  name = "libbson-${version}";

  src = fetchurl {
    url = "https://github.com/mongodb/libbson/releases/download"
      + "/${version}/${name}.tar.gz";
    sha256 = "ac35850ea90fb0de36aa80196eeba484aadaa234d76fe2daae3d8ef3df3c6e61";
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

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
