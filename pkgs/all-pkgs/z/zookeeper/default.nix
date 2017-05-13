{ stdenv
, fetchurl
, lib
, makeWrapper

, bash
, jre
}:

stdenv.mkDerivation rec {
  name = "zookeeper-3.4.10";

  src = fetchurl {
    url = "mirror://apache/zookeeper/${name}/${name}.tar.gz";
    sha256 = "7f7f5414e044ac11fee2a1e0bc225469f51fb0cdf821e67df762a43098223f27";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    jre
  ];

  configurePhase = ":";

  buildPhase = ":";

  installPhase = ''
    mkdir -p $out
    cp -R conf docs lib ${name}.jar $out
    mkdir -p $out/bin
    cp -R bin/{zkCli,zkCleanup,zkEnv}.sh $out/bin
    for i in $out/bin/{zkCli,zkCleanup}.sh; do
      wrapProgram $i \
        --set JAVA_HOME "${jre}" \
        --prefix PATH : "${bash}/bin"
    done
    chmod -x $out/bin/zkEnv.sh
  '';

  meta = with lib; {
    description = "Service for configuration, naming, and synchronization";
    homepage = https://zookeeper.apache.org;
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
