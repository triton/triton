{ stdenv
, fetchurl

, ncurses
}:

let
  version = "2.0.2";
in
stdenv.mkDerivation rec {
  name = "htop-${version}";

  src = fetchurl {
    url = "https://hisham.hm/htop/releases/${version}/${name}.tar.gz";
    multihash = "QmYxK5YMHnM31CskD7WycoUoyykyREqGXe6YoCH1atoxrP";
    sha256 = "179be9dccb80cee0c5e1a1f58c8f72ce7b2328ede30fb71dcdf336539be2f487";
  };

  buildInputs = [
    ncurses
  ];

  meta = with stdenv.lib; {
    description = "An interactive process viewer for Linux";
    homepage = "http://htop.sourceforge.net";
    licenses = license.gpl2;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
