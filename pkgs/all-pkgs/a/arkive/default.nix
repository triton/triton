{ stdenv
, cmake
, fetchgit

, ffmpeg
, lib-bash
}:

stdenv.mkDerivation rec {
  name = "arkive-2016-05-16";

  src = fetchgit {
    version = 1;
    url = "https://github.com/chlorm/arkive.git";
    rev = "538d6413673e6fee40ed0c936a534ca18b24ccf9";
    sha256 = "19hjbn57y2a5gf9hwqr51cy380m5z9qmjmf5rjags3cqc36nqgag";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    ffmpeg
    lib-bash
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
