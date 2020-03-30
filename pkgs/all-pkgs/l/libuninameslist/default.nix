{ stdenv
, fetchurl
, lib
}:

let
  version = "20200313";
in
stdenv.mkDerivation rec {
  name = "libuninameslist-${version}";

  src = fetchurl {
    url = "https://github.com/fontforge/libuninameslist/releases/download/"
      + "${version}/libuninameslist-dist-${version}.tar.gz";
    sha256 = "a8029cd38a32c85da30015ac2fc0a923c25dfc41590f1717cc64756218403183";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

