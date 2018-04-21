{ stdenv
, fetchurl
, lib
}:

let
  version = "2.8";
in
stdenv.mkDerivation rec {
  name = "bash-completion-${version}";

  src = fetchurl {
    url = "https://github.com/scop/bash-completion/releases/download/"
      + "${version}/${name}.tar.xz";
    sha256 = "c01f5570f5698a0dda8dc9cfb2a83744daa1ec54758373a6e349bd903375f54d";
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
