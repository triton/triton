{ stdenv
, fetchurl
, perl
}:

let
  version = "1.9.2";
in
stdenv.mkDerivation rec {
  name = "libbson-${version}";

  src = fetchurl {
    url = "https://github.com/mongodb/libbson/releases/download"
      + "/${version}/${name}.tar.gz";
    sha256 = "0d1de4aa2ea4b223414c1b1aa803fc50d1ab658b327aead857fb4915136d4e34";
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
