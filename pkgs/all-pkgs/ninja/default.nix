{ stdenv
, asciidoc
, fetchFromGitHub
, python
, re2c
}:

stdenv.mkDerivation rec {
  name = "ninja-${version}";
  version = "1.7.1";

  src = fetchFromGitHub {
    owner = "ninja-build";
    repo = "ninja";
    rev = "v${version}";
    sha256 = "ea115372745177ec1e55982fb48cd1b4fc8fb28080fb2d59d0e728d00f9c0e3f";
  };

  nativeBuildInputs = [
    asciidoc
    python
    re2c
  ];

  setupHook = ./setup-hook.sh;

  postPatch = ''
    patchShebangs ./configure.py
  '';

  buildPhase = ''
    runHook 'preBuild'
    ./configure.py '--bootstrap' '--verbose'
    asciidoc doc/manual.asciidoc
    runHook 'postBuild'
  '';

  installPhase = ''
    runHook 'preInstall'
    install -vD 'ninja' "$out/bin/ninja"
    install -vD 'doc/manual.asciidoc' "$out/share/doc/ninja/manual.asciidoc"
    install -vD 'doc/manual.html' "$out/share/doc/ninja/doc/manual.html"
    runHook 'postInstall'
  '';

  meta = with stdenv.lib; {
    description = "Small build system with a focus on speed";
    homepage = http://martine.github.io/ninja/;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
