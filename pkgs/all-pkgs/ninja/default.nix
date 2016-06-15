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
    sha256 = "e16e452272dd651e5156e25fa88152c2650b4e7e62caaeaaf00c5043ff999ed9";
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
      i686-linux
      ++ x86_64-linux;
  };
}
