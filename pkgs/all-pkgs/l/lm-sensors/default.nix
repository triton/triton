{ stdenv
, bison
, fetchurl
, flex
, which

, perl
}:

stdenv.mkDerivation rec {
  name = "lm_sensors-3.4.0";
  
  src = fetchurl rec {
    url = "http://pkgs.fedoraproject.org/repo/pkgs/lm_sensors/"
      + "${name}.tar.bz2/${md5Confirm}/${name}.tar.bz2";
    md5Confirm = "c03675ae9d43d60322110c679416901a";
    sha256 = "07q6811l4pp0f7pxr8bk3s97ippb84mx5qdg7v92s9hs10b90mz0";
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

  parallelInstall = false;

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
