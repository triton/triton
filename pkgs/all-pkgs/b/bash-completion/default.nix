{ stdenv
, fetchurl
}:

let
  version = "2.3";
in
stdenv.mkDerivation rec {
  name = "bash-completion-${version}";

  src = fetchurl {
    url = "https://github.com/scop/bash-completion/releases/download/"
      + "${version}/${name}.tar.xz";
    sha256 = "b2e081af317f3da4fff3a332bfdbebeb5514ebc6c2d2a9cf781180acab15e8e9";
  };

  doCheck = true;
  parallelBuild = false;
  parallelInstall = false;
  parallelCheck = false;

  meta = with stdenv.lib; {
    description = "Programmable completion for the bash shell";
    homepage = "https://github.com/scop/bash-completion/";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
