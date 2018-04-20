{ stdenv
, fetchurl
, lib
, perl

, attr
}:

stdenv.mkDerivation rec {
  name = "libcap-2.25";
  
  src = fetchurl {
    url = "mirror://kernel/linux/libs/security/linux-privs/libcap2/${name}.tar.xz";
    sha256 = "0qjiqc5pknaal57453nxcbz3mn1r4hkyywam41wfcglq3v2qlg39";
  };
  
  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    attr
  ];

  preConfigure = ''
    cd libcap
  '';

  makeFlags = [
    "lib=lib"
  ];

  preBuild = ''
    makeFlagsArray+=("prefix=$out")
  '';

  meta = with lib; {
    description = "Library for working with POSIX capabilities";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
