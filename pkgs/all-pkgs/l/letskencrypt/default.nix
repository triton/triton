{ stdenv
, fetchFromGitHub

, libbsd
, libressl
}:

stdenv.mkDerivation {
  name = "letskencrypt-2016-08-06";

  src = fetchFromGitHub {
    owner = "kristapsdz";
    repo = "letskencrypt-portable";
    rev = "a50e0fa1bd02686372ac36c1de6abc949886622a";
    sha256 = "b71981e402f595c43c50d5bf3cb4af82ea9a9e8249dc42ce894d00e420146321";
  };

  buildInputs = [
    libbsd
    libressl
  ];

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
