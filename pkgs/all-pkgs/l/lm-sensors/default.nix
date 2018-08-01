{ stdenv
, bison
, fetchFromGitHub
, flex
, which

, perl
}:

let
  rev = "dcf23676cc264927ad58ae7960f518689372741a";
  date = "2018-06-29";
in
stdenv.mkDerivation rec {
  name = "lm_sensors-${date}";
  
  src = fetchFromGitHub {
    version = 6;
    owner = "groeck";
    repo = "lm-sensors";
    inherit rev;
    sha256 = "b16e65e97568bfeeae19c050c3ea62931b21c4abb90c2384eebea267881b4f8a";
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
