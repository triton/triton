{ stdenv
, autoreconfHook
, bison
, fetchFromGitHub
, flex
, texinfo
}:

let
  version = "1.7.1";
in
stdenv.mkDerivation rec {
  name = "libconfig-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "hyperrealm";
    repo = "libconfig";
    rev = "v${version}";
    sha256 = "a09bcd3728025388c85b178706ab5f9ab2714980737227da3dd8099d4ac491d7";
  };

  nativeBuildInputs = [
    autoreconfHook
    bison
    flex
    texinfo
  ];

  postPatch = ''
    rm lib/grammar.{h,c} lib/scanner.c
    rm -r m4 aux-build config.* ac_config.h.in
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
