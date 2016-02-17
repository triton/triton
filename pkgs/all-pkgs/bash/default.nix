{ stdenv
, bison
, fetchurl
, texinfo

, readline
}:

let
  version = "4.3";
  realName = "bash-${version}";
  shortName = "bash43";
  baseConfigureFlags = "--with-installed-readline";
  sha256 = "1m14s1f61mf6bijfibcjm9y6pkyvz6gibyl8p4hxq90fisi8gimg";
in

stdenv.mkDerivation rec {
  name = "${realName}-p${toString (builtins.length patches)}";

  src = fetchurl {
    url = "mirror://gnu/bash/${realName}.tar.gz";
    inherit sha256;
  };

  # Note: Bison is needed because the patches above modify parse.y.
  nativeBuildInputs = [
    bison
    texinfo
  ];

  buildInputs = [
    readline
  ];

  patchFlags = "-p0";

  patches =
    let
      patch = nr: sha256:
        fetchurl {
          url = "mirror://gnu/bash/${realName}-patches/${shortName}-${nr}";
          inherit sha256;
        };
    in
    import ./bash-4.3-patches.nix patch;

  NIX_CFLAGS_COMPILE = ''
    -DSYS_BASHRC="/etc/bashrc"
    -DSYS_BASH_LOGOUT="/etc/bash_logout"
    -DDEFAULT_PATH_VALUE="/no-such-path"
    -DSTANDARD_UTILS_PATH="/no-such-path"
    -DNON_INTERACTIVE_LOGIN_SHELLS
    -DSSH_SOURCE_BASHRC
  '';

  configureFlags = baseConfigureFlags;

  postInstall =
    /* Add an `sh' -> `bash' symlink. */ ''
      ln -s bash "$out/bin/sh"
    '';

  outputs = [ "out" "doc" ];

  crossAttrs = {
    configureFlags = baseConfigureFlags +
      " bash_cv_job_control_missing=nomissing bash_cv_sys_named_pipes=nomissing";
  };

  passthru = {
    shellPath = "/bin/bash";
  };

  meta = with stdenv.lib; {
    description = "The standard GNU Bourne again shell";
    homepage = http://www.gnu.org/software/bash/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
