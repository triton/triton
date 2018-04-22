{ stdenv
, fetchurl

, cmake
, ninja
}:

stdenv.mkDerivation rec {
  name = "soxr-0.1.3";

  src = fetchurl {
    url = "mirror://sourceforge/soxr/${name}-Source.tar.xz";
    sha256 = "b111c15fdc8c029989330ff559184198c161100a59312f5dc19ddeb9b5a15889";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = [
    "-DBUILD_TESTS=OFF"
  ];

  meta = with stdenv.lib; {
    description = "The SoX audio resampler library";
    homepage = http://soxr.sourceforge.net;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
