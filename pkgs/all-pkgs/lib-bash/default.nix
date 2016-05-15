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
    rev = "4c90eae609139e4bcbdc5f4b405765d7b8fb2e64";
    sha256 = "0chic4gqxfm2fncc6yzxiz61ynzil0171fyj0smnhgdbfwxd0cpy";
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
