{ stdenv
, fetchFromGitHub

, curl
, libxml2
}:

stdenv.mkDerivation {
  name = "libs3-2015-04-23";

  src = fetchFromGitHub {
    owner = "bji";
    repo = "libs3";
    rev = "11a4e976c28ba525e7d61fbc3867c345a2af1519";
    sha256 = "43020187c916ee454d292fc9cdf7f80ba77a9362099dc15d0cf66510d427c453";
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
