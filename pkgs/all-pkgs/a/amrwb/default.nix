{ stdenv
, fetchurl
, lib
, unzip
}:

stdenv.mkDerivation rec {
  name = "amrwb-11.0.0.0";

  # http://www.3gpp.org/DynaReport/26204.htm
  amrwb_3gpp_version = "26204-g00";  # Rel-16
  amrwb_3gpp = fetchurl {
    url = "http://www.3gpp.org/ftp/Specs/archive/26_series/26.204/"
      + "${amrwb_3gpp_version}.zip";
    multihash = "QmRouou9GMpSEPdW3MCs9qiJVVE1Q3fNLm7H5LKCDpZ23d";
    sha256 = "453cb352be4535abf72842f571e739a251210ddfecdb0d4d1272422ace0b24ce";
  };

  src = fetchurl {
    url = "http://www.penguin.cz/~utx/ftp/amr/${name}.tar.bz2";
    multihash = "QmTK8e9a2a42Zpk3i2BSSYQnpByARjtwhiFU8kAWUJS4g7";
    sha256 = "5caf59b14480b0cd2a7babb8be472c4af39ff4c7c95f1278116557049a4dd5dc";
  };

  nativeBuildInputs = [
    unzip
  ];

  postPatch = /* Fix hardcoded 3GPP source version */ ''
    sed -i Makefile.{in,am} \
      -i configure{,.ac} \
      -i prepare_sources.sh.in \
      -e 's/26204-b00/${amrwb_3gpp_version}/g'
  '' + /* Fix extracted path */ ''
    sed -i prepare_sources.sh.in \
      -e '/@UNZIP@ ${amrwb_3gpp_version}_ANSI/a mv -v ${amrwb_3gpp_version}_ANSI-C_source_code/c-code/ c-code/'
  '' + /* Remove obsolete patch */ ''
    sed -i prepare_sources.sh.in \
      -e '/amrwb-intsizes.patch/d'
  '';

  configureFlags = [
    "--without-downloader"
  ];

  postConfigure = ''
    cp -v "$amrwb_3gpp" '${amrwb_3gpp_version}.zip'
  '';

  meta = with lib; {
    description = "AMR Wide-Band Codec";
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
