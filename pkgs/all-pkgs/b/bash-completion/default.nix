{ stdenv
, fetchurl
, lib
}:

let
  version = "2.5";
in
stdenv.mkDerivation rec {
  name = "bash-completion-${version}";

  src = fetchurl {
    url = "https://github.com/scop/bash-completion/releases/download/"
      + "${version}/${name}.tar.xz";
    sha256 = "b0b9540c65532825eca030f1241731383f89b2b65e80f3492c5dd2f0438c95cf";
  };

  doCheck = true;
  buildParallel = false;
  installParallel = false;
  checkParallel = false;

  meta = with lib; {
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
