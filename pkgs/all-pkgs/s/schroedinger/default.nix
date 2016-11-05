{ stdenv
, fetchurl
, lib

#, mesa
#, nvidia-cuda-toolkit
, orc
}:

let
  inherit (lib)
    boolString
    boolWt;
in
stdenv.mkDerivation rec {
  name = "schroedinger-1.0.11";

  src = fetchurl {
    urls = [
      #"http://diracvideo.org/download/schroedinger/${name}.tar.gz"
      "https://download.videolan.org/contrib/${name}.tar.gz"
    ];
    sha256 = "1e572a0735b92aca5746c4528f9bebd35aa0ccf8619b22fa2756137a8cc9f912";
  };

  buildInputs = [
    #mesa
    #nvidia-cuda-toolkit
    orc
  ];

  # The test suite does not build against Orc >0.4.16.
  postPatch = ''
    sed -i Makefile.in \
      -e 's/ testsuite//'
  '';

  configureFlags = [
    "--enable-largefile"
    "--disable-gcov"
    "--enable-encoder"
    "--enable-motion-ref"
    "--disable-gtk-doc"
    #"--${boolWt (mesa != null)}-opengl${
    #    boolString (mesa != null) "=${mesa}" ""}"
    "--without-opengl"
    #"--${boolWt (nvidia-cuda-toolkit != null)}-cuda${
    #    boolString (nvidia-cuda-toolkit != null) "=${nvidia-cuda-toolkit}" ""}"
    "--without-cuda"
  ];

  meta = with stdenv.lib; {
    description = "Libraries for the Dirac video codec";
    homepage = "http://diracvideo.org/";
    license = with licenses; [
      mpl11
      lgpl2
      mit
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
