{ stdenv
, fetchurl
}:

let
  version = "1.2.7";
in
stdenv.mkDerivation rec {
  name = "exfat-utils-${version}";

  src = fetchurl {
    url = "https://github.com/relan/exfat/releases/download/v${version}/${name}.tar.gz";
    sha256 = "386132d155b92c7d27735483663f2724844cb904ef9ecd83c374cffe831dffe4";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
