{ stdenv
, cmake
#, fetchFromGitHub
, fetchgit
}:

stdenv.mkDerivation rec {
  name = "lib-bash-2016-05-14";

  src = fetchgit {
    #owner = "chlorm";
    #repo = "lib-bash";
    url = "https://github.com/chlorm/lib-bash.git";
    rev = "25db380851c0b0828ec6654afb708180612f101e";
    sha256 = "14gji63fkspa36aly35v4q0q6cjd3a6zm1795gwi2c9dghn7j9gs";
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
