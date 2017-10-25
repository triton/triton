{ stdenv
, fetchurl
, lib
, nasm
}:

stdenv.mkDerivation rec {
  name = "xvidcore-1.3.4";

  src = fetchurl {
    url = "http://downloads.xvid.org/downloads/${name}.tar.bz2";
    sha256 = "1xwbmp9wqshc0ckm970zdpi0yvgqxlqg0s8bkz98mnr8p2067bsz";
  };

  postUnpack = ''
    srcRoot="$sourceRoot/build/generic"
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

