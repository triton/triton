{ stdenv
, bison
, fetchurl
, flex
, which
}:

stdenv.mkDerivation rec {
  name = "lm-sensors-3.4.0";
  
  src = fetchurl {
    url = "http://pkgs.fedoraproject.org/repo/pkgs/lm_sensors/lm_sensors-3.4.0.tar.bz2/c03675ae9d43d60322110c679416901a/lm_sensors-3.4.0.tar.bz2";
    sha256 = "07q6811l4pp0f7pxr8bk3s97ippb84mx5qdg7v92s9hs10b90mz0";
  };

  nativeBuildInputs = [
    bison
    flex
    which
  ];

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
    buildFlagsArray+=("ETCDIR=/etc")
    installFlagsArray+=("ETCDIR=$out/etc")
  '';

  meta = with stdenv.lib; {
    homepage = http://www.lm-sensors.org/;
    description = "Tools for reading hardware sensors";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
