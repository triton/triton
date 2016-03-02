{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec{
  name = "amrnb-11.0.0.0";

  srcAmr = fetchurl {
    url = http://www.3gpp.org/ftp/Specs/latest/Rel-11/26_series/26104-b00.zip;
    sha256 = "1wf8ih0hk7w20vdlnw7jb7w73v15hbxgbvmq4wq7h2ghn0j8ppr3";
  };

  src = fetchurl {
    url = "http://www.penguin.cz/~utx/ftp/amr/${name}.tar.bz2";
    sha256 = "1qgiw02n2a6r32pimnd97v2jkvnw449xrqmaxiivjy2jcr5h141q";
  };

  nativeBuildInputs = [
    unzip
  ];

  configureFlags = [
    "--without-downloader"
  ];

  postConfigure = ''
    cp $srcAmr 26104-b00.zip
  '';

  meta = with stdenv.lib; {
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
