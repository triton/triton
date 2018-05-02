{ stdenv
, bison
, fetchFromGitHub
, flex

, hiredis
, zeromq
}:

let
  version = "7.0.0";
in
stdenv.mkDerivation {
  name = "pf-ring-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "ntop";
    repo = "PF_RING";
    rev = version;
    sha256 = "eb53596c254c7f21f4bb96b8b762fc4e8b294f407926600872988790e6da34ff";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  buildInputs = [
    hiredis
    zeromq
  ];

  postPatch = ''
    sed -i 's, lex$, flex,' userland/nbpf/Makefile.in
  '';

  preConfigure = ''
    cd userland/lib
  '';

  configureFlags = [
    "--enable-redis"
    "--enable-zmq"
  ];

  postInstall = ''
    cp -r ../../kernel/linux "$out/include"
  '';

  # Parallel building is broken
  buildParallel = false;
  installParallel = false;

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
