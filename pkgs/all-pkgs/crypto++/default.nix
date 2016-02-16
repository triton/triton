{ fetchurl
, stdenv
, unzip
}:

stdenv.mkDerivation rec {
  name = "crypto++-5.6.3";

  src = fetchurl {
    url = "mirror://sourceforge/cryptopp/cryptopp563.zip";
    sha256 = "1japr6fhdxpn56is2627dl2lpvv98bvhcsvbibsd038p2h56g44k";
  };

  nativeBuildInputs = [
    unzip
  ];

  sourceRoot = ".";

  postPatch = ''
    mv config.recommend config.h

    sed \
      -e 's|-march=[^ ]*|-march=${stdenv.platform.march}|g' \
      -e 's|-mtune=[^ ]*|-mtune=${stdenv.platform.mtune}|g' \
      -i GNUmakefile
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
    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
  };
}

