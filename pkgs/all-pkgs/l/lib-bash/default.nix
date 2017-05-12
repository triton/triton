{ stdenv
, cmake
, fetchFromGitHub
, lib
}:

stdenv.mkDerivation rec {
  name = "lib-bash-2016-12-21";

  src = fetchFromGitHub {
    version = 3;
    owner = "chlorm";
    repo = "lib-bash";
    rev = "cb72b622d2d865b1e1bdb364d1fad1fa1b274d60";
    sha256 = "893ba9a9faa8efbd1f20d341dbad69b888b61e16799e13a185c5cab5818f1172";
  };

  nativeBuildInputs = [
    cmake
  ];

  meta = with lib; {
    description = "A standard library of sorts for shell scripting";
    homepage = https://github.com/chlorm/lib-bash;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
