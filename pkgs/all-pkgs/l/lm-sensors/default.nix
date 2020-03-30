{ stdenv
, bison
, fetchFromGitHub
, flex
, which

, perl
}:

let
  rev = "248d4a17a59cd3366f5594a360353997571e0b68";
  date = "2020-02-21";
in
stdenv.mkDerivation rec {
  name = "lm_sensors-${date}";
  
  src = fetchFromGitHub {
    version = 6;
    owner = "lm-sensors";
    repo = "lm-sensors";
    inherit rev;
    sha256 = "956a22f16d625a66dc75709fcc7572595352b2cf20978593c8935353dcadf510";
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
