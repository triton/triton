{ stdenv
, fetchurl
, python2

, ncurses
}:

let
  version = "2.1.0";
in
stdenv.mkDerivation rec {
  name = "htop-${version}";

  src = fetchurl {
    url = "https://hisham.hm/htop/releases/${version}/${name}.tar.gz";
    multihash = "QmPkY2DFLYqFgyHpbBy6rG3tp2pYJnxovqcQ6Z79b72fQ6";
    sha256 = "3260be990d26e25b6b49fc9d96dbc935ad46e61083c0b7f6df413e513bf80748";
  };

  nativeBuildInputs = [
    python2
  ];

  buildInputs = [
    ncurses
  ];

  postPatch = ''
    patchShebangs scripts/MakeHeader.py
  '';

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
