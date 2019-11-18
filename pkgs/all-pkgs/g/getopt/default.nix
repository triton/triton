{ stdenv
, fetchurl
, gettext
}:

stdenv.mkDerivation rec {
  name = "getopt-1.1.6";

  src = fetchurl {
    url = "http://frodo.looijaard.name/system/files/software/getopt/${name}.tar.gz";
    multihash = "Qmck3cYDdP3V66u59i6ioYLBwCiS3uB3gR6PJd8i48Gw2N";
    sha256 = "1zn5kp8ar853rin0ay2j3p17blxy16agpp8wi8wfg4x98b31vgyh";
  };

  nativeBuildInputs = [
    gettext.bin
  ];

  preBuild = ''
    makeFlagsArray+=("prefix=$bin")
  '';

  postInstall = ''
    mkdir -p "$man"/share
    mv -v "$bin"/man "$man"/share
  '';

  outputs = [
    "bin"
    "man"
  ];

  meta = with stdenv.lib; {
    description = "Program to help shell scripts parse command-line parameters";
    homepage = "http://frodo.looijaard.name/project/getopt";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
