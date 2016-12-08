{ stdenv
, fetchFromGitHub

, hiredis
}:

let
  version = "6.4.1";
in
stdenv.mkDerivation {
  name = "pf-ring-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "ntop";
    repo = "PF_RING";
    rev = "v${version}";
    sha256 = "9a11ba708741b05a1705548bb1a249794030df813bd542447aab231a105fd24f";
  };

  buildInputs = [
    hiredis
  ];

  preConfigure = ''
    cd userland/lib
  '';

  preBuild = ''
    cat config.log
  '';

  configureFlags = [
    "--enable-redis"
  ];

  postInstall = ''
    cp -r ../../kernel/linux "$out/include"
  '';

  # Parallel building is broken
  parallelBuild = false;
  parallelInstall = false;

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
