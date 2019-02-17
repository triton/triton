{ stdenv
, fetchurl
, lib
, unzip
}:

stdenv.mkDerivation rec{
  name = "amrnb-11.0.0.0";

  # http://www.3gpp.org/DynaReport/26104.htm
  amrnb_3gpp_version = "26104-g00";  # Rel-16
  amrnb_3gpp = fetchurl {
    url = "http://www.3gpp.org/ftp/Specs/archive/26_series/26.104/"
      + "${amrnb_3gpp_version}.zip";
    multihash = "Qma62vUUSoNXrBUS2dz158Ybgo6XgmcVG8krUNQvnEkD3o";
    sha256 = "97b164b9b9079e7979a4e14ae79ed9a0749b8cc3b778fa7ebacd6d5eadc5976f";
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
      -e 's/26104-b00/${amrnb_3gpp_version}/g'
  '' + /* Patch no longer necessary */ ''
    grep -q 'amrnb-intsizes.patch' prepare_sources.sh.in
    sed -i prepare_sources.sh.in \
      -e '/amrnb-intsizes.patch/d'
  '';

  configureFlags = [
    "--without-downloader"
  ];

  preConfigure = ''
    cp -v "$amrnb_3gpp" '${amrnb_3gpp_version}.zip'
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
