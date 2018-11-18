{ stdenv
, fetchurl
, lib
, pkg-config
}:

let
  version = "2.8";

  inherit (pkg-config.variable)
    installSysDir;
in
stdenv.mkDerivation rec {
  name = "bash-completion-${version}";

  src = fetchurl {
    url = "https://github.com/scop/bash-completion/releases/download/"
      + "${version}/${name}.tar.xz";
    sha256 = "c01f5570f5698a0dda8dc9cfb2a83744daa1ec54758373a6e349bd903375f54d";
  };

  # Fix the .pc file to use the special installSysDir
  preFixup = ''
    sed \
      -e '1i${installSysDir}=/no-such-path' \
      -e 's,^prefix=.*,prefix=''${${installSysDir}},' \
      -i "$out"/share/pkgconfig/bash-completion.pc
  '';

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
