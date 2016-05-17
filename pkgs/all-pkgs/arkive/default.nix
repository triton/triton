{ stdenv
, cmake
, fetchgit

, ffmpeg
}:

stdenv.mkDerivation rec {
  name = "arkive-2016-05-16";

  src = fetchgit {
    url = "https://github.com/chlorm/arkive.git";
    rev = "b9f98b00897531f2f183004b71f11507d9da3d34";
    sha256 = "06h07rcbmsz7zdq8f22v49ibs5yn4666wqrxb1p456n15vjgqmh0";
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
