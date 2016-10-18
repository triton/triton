{ stdenv
, cmake
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "lib-bash-2016-10-16";

  src = fetchFromGitHub {
    version = 2;
    owner = "chlorm";
    repo = "lib-bash";
    rev = "abb084744afe7a5345d8c5bae5ee9c0b178af581";
    sha256 = "195e24ecd19b56fd7a6fb55feb324952a58ec2e4e5fad6b388f74e12d9f681ab";
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
