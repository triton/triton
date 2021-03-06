{ stdenv
, fetchurl

, oniguruma
}:

stdenv.mkDerivation rec {
  name = "jq-1.6";

  src = fetchurl {
    url = "https://github.com/stedolan/jq/releases/download/${name}/${name}.tar.gz";
    sha256 = "5de8c8e29aaa3fb9cc6b47bb27299f271354ebb72514e3accadc7d38b5bbaa72";
  };

  buildInputs = [
    oniguruma
  ];

  configureFlags = [
    "--disable-docs"
  ];

  postInstall = ''
    mkdir -p "$bin"
    mv -v "$dev"/bin "$bin"

    mkdir -p "$lib"/lib
    mv -v "$dev"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$dev"/lib
  '';

  postFixup = ''
    rm -rv "$dev"/share
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
    "man"
  ];

  meta = with stdenv.lib; {
    description = "A lightweight and flexible command-line JSON processor";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
