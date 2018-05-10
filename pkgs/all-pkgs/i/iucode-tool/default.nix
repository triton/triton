{ stdenv
, autoreconfHook
, fetchzip
, lib
}:

let
  version = "2.3.1";
in
stdenv.mkDerivation {
  name = "iucode-tool-${version}";

  src = fetchzip {
    version = 6;
    url = "https://gitlab.com/iucode-tool/iucode-tool/-/archive/v${version}/iucode-tool-v${version}.tar.bz2";
    multihash = "QmS8RmVrhm2YLovDwr8GnnVNuHbp1pjyXjjP9sedJEaqJA";
    sha256 = "52056cd3d3b92b1cd3eeac83683592f88dcbaa48fdf0852c039e208c867b13eb";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
