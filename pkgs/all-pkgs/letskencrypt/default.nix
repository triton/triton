{ stdenv
, fetchFromGitHub

, libbsd
, libressl
}:

stdenv.mkDerivation {
  name = "letskencrypt-2016-07-16";

  src = fetchFromGitHub {
    owner = "kristapsdz";
    repo = "letskencrypt-portable";
    rev = "f190947f611a15938b30101969adab72176ef3c9";
    sha256 = "d26a0a8105ac3061fedf4a04df804708a6a78a11ae7959a45fb90bffade6a2cb";
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
