{ stdenv
, asciidoc
, fetchurl
, python
, re2c
}:

stdenv.mkDerivation rec {
  name = "ninja-${version}";
  version = "1.6.0";

  src = fetchurl {
    url = "https://github.com/martine/ninja/archive/v${version}.tar.gz";
    sha256 = "1ryd1686bd31gfdjxnqm6k1ybnjmjz8v97px7lmdkr4g0vxqhgml";
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
