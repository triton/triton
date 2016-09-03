{ stdenv
, fetchFromGitHub

, curl
, libxml2
}:

stdenv.mkDerivation {
  name = "libs3-2015-04-23";

  src = fetchFromGitHub {
    version = 1;
    owner = "bji";
    repo = "libs3";
    rev = "11a4e976c28ba525e7d61fbc3867c345a2af1519";
    sha256 = "55e5655cd59d676efdbb242d8426b0b25cfe6312ff2b78755679d755d1667e35";
  };

  buildInputs = [
    curl
    libxml2
  ];

  preBuild = ''
    export DESTDIR="$out"
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/bji/libs3;
    description = "A library for interfacing with amazon s3";
    license = licenses.lgpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
