{ stdenv
, cmake
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "lib-bash-2016-09-20";

  src = fetchFromGitHub {
    version = 2;
    owner = "chlorm";
    repo = "lib-bash";
    rev = "d59cc8a1af6937e06ee662f24a5664b89c3e735c";
    sha256 = "68fb7ca59fcc07030882efc4d62ea6d1bbc120967a8234faeba3651345719645";
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
