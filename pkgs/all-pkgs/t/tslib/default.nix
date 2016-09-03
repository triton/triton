{ stdenv
, autoreconfHook
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "tslib-2015-08-20";
  
  src = fetchFromGitHub {
    version = 1;
    owner = "kergoth";
    repo = "tslib";
    rev = "0a11148eff4111afc8b241b59fdca541fcfa69c1";
    sha256 = "c484a8ba9479c846082b2a84ca8104320ce69e763d5078f61ba64518c28369c4";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
