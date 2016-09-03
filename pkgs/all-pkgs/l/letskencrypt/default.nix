{ stdenv
, fetchFromGitHub

, libbsd
, libressl
}:

stdenv.mkDerivation {
  name = "letskencrypt-2016-08-22";

  src = fetchFromGitHub {
    version = 1;
    owner = "kristapsdz";
    repo = "letskencrypt-portable";
    rev = "ec55b5616bbeef9388fe5a2a557b319c6653a763";
    sha256 = "00cb44b6c9f278410292109369c5d4cc56fdbcf2de324454bdea10c5c6ee6f0e";
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
