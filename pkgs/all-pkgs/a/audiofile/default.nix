{ stdenv
, fetchTritonPatch
, fetchurl
, lib

, flac
}:

stdenv.mkDerivation rec {
  name = "audiofile-0.3.6";

  src = fetchurl {
    urls = [
      "http://audiofile.68k.org/${name}.tar.xz"
      "mirror://gentoo/distfiles/${name}.tar.xz"
    ];
    sha256 = "ea2449ad3f201ec590d811db9da6d02ffc5e87a677d06b92ab15363d8cb59782";
  };

  buildInputs = [
    flac
  ];

  patches = [
    (fetchTritonPatch {
      rev = "28068ed0937ac9025e0605b18dd3c382d2eabad4";
      file = "audiofile/audiofile-0.3.6-CVE-2015-7747.patch";
      sha256 = "046a53b517440047a6cde81da45c6ed8611298e393b878debc1e7a8c86a4468f";
    })
  ];

  configureFlags = [
    "--enable-largefile"
    "--disable-werror"
    "--disable-coverage"
    "--disable-docs"
    "--disable-examples"
    "--enable-flac"
  ];

  CXXFLAGS = "-std=c++03";

  meta = with lib; {
    description = "Library for reading & writing various audio file formats";
    homepage = http://www.68k.org/~michael/audiofile/;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
