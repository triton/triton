{ stdenv
, fetchFromGitHub

, glib
, sqlite
}:

let
  date = "2017-10-11";
  rev = "8fb519f6b9128d0ae4134ff2f8af85ff53b87f72";
in
stdenv.mkDerivation rec {
  name = "duperemove-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "markfasheh";
    repo = "duperemove";
    inherit rev;
    sha256 = "7044c1f884196ebd3c06561c0c4c24eaa2a2891cae25f2a2994e99d5270086c4";
  };

  buildInputs = [
    glib
    sqlite
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
