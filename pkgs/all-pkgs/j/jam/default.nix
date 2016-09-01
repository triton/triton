{ stdenv
, fetchurl
, bison
}:

stdenv.mkDerivation rec {
  name = "jam-2.6";

  src = fetchurl {
    url = "https://swarm.workshop.perforce.com/downloads/guest/"
      + "perforce_software/jam/${name}.tar";
    multihash = "QmdMLw43Jy8brhMv3zMz2Z9b78Zjz3p6aXr56u9HYJuWhK";
    sha256 = "16fe402b8603c34027e7f39e047a9597129c52c4a67079add5b3842f593f9948";
  };

  nativeBuildInputs = [
    bison
  ];

  setupHook = ./setup-hook.sh;

  installPhase = ''
    install -D -m 755 -v 'jam0' "$out/bin/jam"
  '';

  meta = with stdenv.lib; {
    homepage = https://swarm.workshop.perforce.com/projects/perforce_software-jam;
    description = "Just Another Make";
    license = with licenses; [
      gpl2
      #perforce
    ];
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
