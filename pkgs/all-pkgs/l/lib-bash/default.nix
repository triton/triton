{ stdenv
, cmake
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "lib-bash-2016-07-17";

  src = fetchFromGitHub {
    owner = "chlorm";
    repo = "lib-bash";
    rev = "3dd5796244253b6eb38209bfa5a89ce935c974c5";
    sha256 = "717df96ecde5b004f9e586a9d58cb2b954fca9d7ce007c39ed0d6a69f94c7366";
  };

  nativeBuildInputs = [
    cmake
  ];

  meta = with stdenv.lib; {
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
