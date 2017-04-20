{ stdenv
, fetchurl

, ncurses
}:

let
  version = "2.7.1";
  id = "4215";
in
stdenv.mkDerivation rec {
  name = "minicom-${version}";

  src = fetchurl {
    url = "https://alioth.debian.org/frs/download.php/file/${id}/${name}.tar.gz";
    multihash = "QmdGxYm6sKNTjHkGW3aN8WWfJFNSuM5mH99RC6sYdHnPgR";
    sha256 = "532f836b7a677eb0cb1dca8d70302b73729c3d30df26d58368d712e5cca041f1";
  };

  buildInputs = [
    ncurses
  ];

  postPatch = ''
    sed -i 's/test -d \$UUCPLOCK/true/g' configure
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-lock-dir=/var/lock"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
