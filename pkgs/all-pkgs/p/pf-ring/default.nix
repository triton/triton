{ stdenv
, bison
, fetchFromGitHub
, flex

, hiredis
, zeromq
}:

let
  version = "6.6.0";
in
stdenv.mkDerivation {
  name = "pf-ring-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "ntop";
    repo = "PF_RING";
    rev = version;
    sha256 = "52274b6ae2208da6294cc9036641b18b18825377a38ef90a1662dba58c2f6404";
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
