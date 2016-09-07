{ stdenv
, fetchurl
}:

let
  version = "2.4";
in
stdenv.mkDerivation rec {
  name = "bash-completion-${version}";

  src = fetchurl {
    url = "https://github.com/scop/bash-completion/releases/download/"
      + "${version}/${name}.tar.xz";
    sha256 = "c0f76b5202fec9ef8ffba82f5605025ca003f27cfd7a85115f838ba5136890f6";
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
