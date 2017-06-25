{ stdenv
, fetchFromGitHub
, lib
, makeWrapper
, which

, go
, python2
}:

stdenv.mkDerivation rec {
  name = "grumpy-2017-06-19";

  src = fetchFromGitHub {
    version = 3;
    owner = "google";
    repo = "grumpy";
    rev = "f1446cd91c750b2439a1eb9a1e92f736a9fbb551";
    sha256 = "ce44408b10de1cf27fc0a6b5bf3a70cb13f41954c9a7450b563fbe288f248fb0";
  };

  nativeBuildInputs = [
    makeWrapper
    which
  ];

  buildInputs = [
    go
    python2
  ];

  postPatch = ''
    sed -i Makefile \
      -e "s,/usr,$out,g" \
      -e 's/version 2>&1/version/'
  '';

  preBuild = /* Install python libs in correct prefix */ ''
    makeFlagsArray+=(
      "PY_INSTALL_DIR=$out/${python2.sitePackages}"
    )
  '';

  preFixup = ''
    for Program in $out/bin/grump{c,run}; do
      wrapProgram  "$Program" \
        --prefix 'GOPATH' : "$out" \
        --prefix 'PYTHONPATH' : "$out/${python2.sitePackages}"
    done
  '';

  buildDirCheck = false;

  meta = with lib; {
    description = "Python to Go source code transcompiler and runtime";
    homepage = https://github.com/google/grumpy;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
