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
    rev = "0bf41c1ddf84752bf79e2dd8afbab4891853a11f";
    sha256 = "03ap82m2iqwhpi0i49dqj8pz4chfs9j0gxajybciaj8xhnp73jpq";
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
