{ stdenv
, cmake
#, fetchFromGitHub
, fetchgit
}:

stdenv.mkDerivation rec {
  name = "lib-bash-2016-05-18";

  src = fetchgit {
    #owner = "chlorm";
    #repo = "lib-bash";
    url = "https://github.com/chlorm/lib-bash.git";
    rev = "65606f8fc95e6001981036d013cbd379e46716b3";
    sha256 = "054y8hf4vnhfdhsw5qx6wm1k0fij8nlysaggydxzpkf6fryv9czi";
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
