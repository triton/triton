{ stdenv
, cmake
#, fetchFromGitHub
, fetchgit
}:

stdenv.mkDerivation rec {
  name = "lib-bash-2016-05-22";

  src = fetchgit {
    #owner = "chlorm";
    #repo = "lib-bash";
    url = "https://github.com/chlorm/lib-bash.git";
    rev = "297497796e06be22976a35d57ce4eb628be297aa";
    sha256 = "00d3gq17c3yvc3j08706048hfncpmpnfhi3wzw8vnb3n7755955d";
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
