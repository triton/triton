{ stdenv
, fetchurl
, python2

, ncurses
}:

let
  version = "2.2.0";
in
stdenv.mkDerivation rec {
  name = "htop-${version}";

  src = fetchurl {
    url = "https://hisham.hm/htop/releases/${version}/${name}.tar.gz";
    multihash = "QmNUCyueoLPGSTevC3kmn2wZ1ez3RoGrLo1U6RsGGA899o";
    sha256 = "d9d6826f10ce3887950d709b53ee1d8c1849a70fa38e91d5896ad8cbc6ba3c57";
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
