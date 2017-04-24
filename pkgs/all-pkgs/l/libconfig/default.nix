{ stdenv
, autoreconfHook
, bison
, fetchFromGitHub
, flex
, texinfo
}:

let
  version = "1.6";
in
stdenv.mkDerivation rec {
  name = "libconfig-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "hyperrealm";
    repo = "libconfig";
    rev = "v${version}";
    sha256 = "3ab6e31c0d975e52bc37eae86e3bce2e57441895f728188ad6deb2bcbb39f09c";
  };

  nativeBuildInputs = [
    autoreconfHook
    bison
    flex
    texinfo
  ];

  postPatch = ''
    rm lib/grammar.{h,c} lib/scanner.c
    rm -r m4 aux-build aclocal.m4 config.* configure ac_config.h.in
    find . -name Makefile.in -delete
  '';

  configureFlags = [
    "--disable-examples"
  ];

  preBuild = ''
    cat -n lib/Makefile
  '';

  postInstall = ''
    rm -rf "$out"/share
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
