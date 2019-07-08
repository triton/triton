{ stdenv
, bison
, fetchFromGitHub
, flex
, which

, perl
}:

let
  rev = "7daa6c5ed50215faa2b08fe1184a7b3f30194bef";
  date = "2019-07-05";
in
stdenv.mkDerivation rec {
  name = "lm_sensors-${date}";
  
  src = fetchFromGitHub {
    version = 6;
    owner = "lm-sensors";
    repo = "lm-sensors";
    inherit rev;
    sha256 = "456d31d28f6fde4b5c78da54ce5faa8fbcf6e426129f70b095877a51966cada8";
  };

  nativeBuildInputs = [
    bison
    flex
    which
  ];

  buildInputs = [
    perl  # Needed for sensors-detect
  ];

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
    buildFlagsArray+=("ETCDIR=/etc")
    installFlagsArray+=("ETCDIR=$out/etc")
  '';

  installParallel = false;

  meta = with stdenv.lib; {
    homepage = http://www.lm-sensors.org/;
    description = "Tools for reading hardware sensors";
    license = with licenses; [
      gpl2
      lgpl21
    ];
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
