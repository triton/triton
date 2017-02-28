{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation {
  name = "flashmap-2017-02-17";

  src = fetchFromGitHub {
    version = 2;
    owner = "dhendrix";
    repo = "flashmap";
    rev = "976420e9ecae3c3933d5e59e67a4debad751d003";
    sha256 = "792608d6f1486d7e7e4f61625a62a4a0dbc0a26c8276518b481b4a16e1c29576";
  };

  preBuild = ''
    makeFlagsArray+=("prefix=$out")
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
