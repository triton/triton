{ stdenv
, bison
, fetchFromGitHub
, flex
, which

, perl
}:

let
  rev = "84f773b3ec8b75f377a68fd1436ea3ac6d11b170";
  date = "2018-11-23";
in
stdenv.mkDerivation rec {
  name = "lm_sensors-${date}";
  
  src = fetchFromGitHub {
    version = 6;
    owner = "lm-sensors";
    repo = "lm-sensors";
    inherit rev;
    sha256 = "f656d1597d95fdfc65ffe242a69841e9838ac7569fb5a22f9a7f75ecdd8a3915";
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
