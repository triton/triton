{ stdenv
, fetchurl
, lib
, nasm
}:

stdenv.mkDerivation rec {
  name = "xvidcore-1.3.5";

  src = fetchurl {
    url = "http://downloads.xvid.org/downloads/${name}.tar.bz2";
    sha256 = "7c20f279f9d8e89042e85465d2bcb1b3130ceb1ecec33d5448c4589d78f010b4";
  };

  postUnpack = ''
    srcRoot="$srcRoot/build/generic"
  '';

  nativeBuildInputs = [
    nasm
  ];

  configureFlags = [
    "--disable-idebug"
    "--disable-iprofile"
    "--disable-gnuprofile"
    "--enable-assembly"
    "--enable-pthread"
    "--disable-macosx_module"
  ];

  postInstall = ''
    rm -v $out/lib/*.a
  '';

  meta = with lib; {
    description = "MPEG-4 video de/encoding solution";
    homepage = https://www.xvid.com/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
