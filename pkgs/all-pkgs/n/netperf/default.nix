{ stdenv
, autoconf
, automake
, fetchFromGitHub
, lib
, libtool
}:

let
  date = "2017-09-21";
  rev = "d566775bf2e0f87b3d81bd799cccd40fda2de133";
in
stdenv.mkDerivation {
  name = "netperf-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "HewlettPackard";
    repo = "netperf";
    inherit rev;
    sha256 = "78219c29ae9a00e7a2d8e60804b5f3c201091ab40604669bf6694eb0dcef1c61";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
