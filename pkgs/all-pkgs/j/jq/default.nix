{ stdenv
, fetchurl

, oniguruma
}:

stdenv.mkDerivation rec {
  name = "jq-1.6";

  src = fetchurl {
    url = "https://github.com/stedolan/jq/releases/download/${name}/${name}.tar.gz";
    sha256 = "9625784cf2e4fd9842f1d407681ce4878b5b0dcddbcd31c6135114a30c71e6a8";
  };

  buildInputs = [
    oniguruma
  ];

  configureFlags = [
    "--disable-docs"
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
