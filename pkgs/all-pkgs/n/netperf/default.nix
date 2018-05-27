{ stdenv
, autoconf
, automake
, fetchFromGitHub
, lib
, libtool
}:

let
  date = "2018-05-04";
  rev = "c0a0d9f31f9940abf375a41b43a343cdbf87caab";
in
stdenv.mkDerivation {
  name = "netperf-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "HewlettPackard";
    repo = "netperf";
    inherit rev;
    sha256 = "1f56c8bb25adb5044718bc590fc0cee0b68a3a809abe9cb64b1332552b05afeb";
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
