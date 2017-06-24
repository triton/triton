{ stdenv
, fetchurl
, lib
, unzip
}:

stdenv.mkDerivation rec{
  name = "amrnb-11.0.0.0";

  # http://www.3gpp.org/DynaReport/26104.htm
  # NOTE: When updating amrnb-3gpp, update every instance of 26104-e00 to the
  #       updated file name.
  amrnb_3gpp = fetchurl {
    # Rel-14
    url = "http://www.3gpp.org/ftp/Specs/archive/26_series/26.104/26104-e00.zip";
    multihash = "QmaQRi5VKMGgRTgxhjARAbNB5aTgKCLpskfCvg3QwEoGH9";
    sha256 = "5d0c70576cea76bf200c6412306a6152758391b1aa40e7e14271169bbafa9125";
  };

  src = fetchurl {
    url = "http://www.penguin.cz/~utx/ftp/amr/${name}.tar.bz2";
    multihash = "QmbeaQgStCwmNCUDfiX6LKPVxpC14SETBAvVr4P7k3t6m1";
    sha256 = "3890004b665278b963ecaae2dc1321dcee29c53ea9d91aaf18d9286105e0f1e1";
  };

  nativeBuildInputs = [
    unzip
  ];

  postPatch = /* Fix hardcoded 3GPP source version */ ''
    sed -i Makefile.{in,am} \
      -i configure{,.ac} \
      -i prepare_sources.sh.in \
      -e 's/26104-b00/26104-e00/g'
  '';

  configureFlags = [
    "--without-downloader"
  ];

  preConfigure = ''
    cp -v $amrnb_3gpp 26104-e00.zip
  '';

  meta = with lib; {
    description = "AMR Narrow-Band Codec";
    homepage = http://www.penguin.cz/~utx/amr;
    # The wrapper code is free, but not the libraries from 3gpp.
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
