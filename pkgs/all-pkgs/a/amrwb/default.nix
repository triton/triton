{ stdenv
, fetchurl
, unzip
}:

stdenv.mkDerivation rec {
  name = "amrwb-11.0.0.0";

  # http://www.3gpp.org/DynaReport/26204.htm
  # NOTE: When updating amrwb-3gpp, update every instance of 26204-d10 to the
  #       updated file name.
  amrwb_3gpp = fetchurl {
    # Rel-13
    url = http://www.3gpp.org/ftp/Specs/archive/26_series/26.204/26204-d10.zip;
    sha256 = "c922636b1878e77d1d4a96bb9c4a014312edef280e1a6939d927acc1775c3452";
  };

  src = fetchurl {
    url = "http://www.penguin.cz/~utx/ftp/amr/${name}.tar.bz2";
    sha256 = "5caf59b14480b0cd2a7babb8be472c4af39ff4c7c95f1278116557049a4dd5dc";
  };

  nativeBuildInputs = [
    unzip
  ];

  postPatch = /* Fix hardcoded 3GPP source version */ ''
    sed -i Makefile.{in,am} \
      -i configure{,.ac} \
      -i prepare_sources.sh.in \
      -e 's/26204-b00/26204-d10/g'
  '';

  configureFlags = [
    "--without-downloader"
  ];

  postConfigure = ''
    cp -v $amrwb_3gpp 26204-d10.zip
  '';

  meta = with stdenv.lib; {
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
