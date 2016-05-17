{ stdenv
, cmake
, fetchgit

, ffmpeg
}:

stdenv.mkDerivation rec {
  name = "arkive-2016-05-16";

  src = fetchgit {
    url = "https://github.com/chlorm/arkive.git";
    rev = "bc762b2f268fdbcd1d5a6af4918aed3696e5c5af";
    sha256 = "13yl4jx77666zkdhvbsx426myyg3lhjs438wdcl2i5dmdwg3b7wz";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    ffmpeg
  ];

  meta = with stdenv.lib; {
    description = "Video encoding automation scripts";
    homepage = https://github.com/chlorm/arkive/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
