{ stdenv
, fetchurl
, unzip
}:

let
  inherit (stdenv.lib)
    replaceStrings;

  version = "5.6.4";

  versionNoDecimal = replaceStrings ["."] [""] version;
in
stdenv.mkDerivation rec {
  name = "cryptopp-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/cryptopp/cryptopp/${version}/cryptopp${versionNoDecimal}.zip";
    sha256 = "be430377b05c15971d5ccb6e44b4d95470f561024ed6d701fe3da3a188c84ad7";
  };

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  postPatch = ''
    mv config.recommend config.h
  '';

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
    buildFlagsArray+=("libcryptopp.so")
  '';

  preFixup = ''
    rm -r $out/bin
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Crypto++, a free C++ class library of cryptographic schemes";
    homepage = http://cryptopp.com/;
    license = licenses.boost;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

