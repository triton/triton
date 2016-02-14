{ stdenv
, fetchurl
, unzip
}:

stdenv.mkDerivation rec {
  name = "amrwb-11.0.0.0";

  srcAmr = fetchurl {
    url = http://www.3gpp.org/ftp/Specs/archive/26_series/26.204/26204-b00.zip;
    sha256 = "1v4zhs6f1mf1xkrzhljh05890in0rpr5d5pcak9h4igxhd2c91f8";
  };

  src = fetchurl {
    url = "http://www.penguin.cz/~utx/ftp/amr/${name}.tar.bz2";
    sha256 = "1p6m9nd08mv525w14py9qzs9zwsa5i3vxf5bgcmcvc408jqmkbsw";
  };

  configureFlags = [
    "--without-downloader"
  ];

  postConfigure = ''
    cp $srcAmr 26204-b00.zip
  '';

  nativeBuildInputs = [
    unzip
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "AMR Wide-Band Codec";
    homepage = http://www.penguin.cz/~utx/amr;
    # The wrapper code is free, but not the libraries from 3gpp.
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
