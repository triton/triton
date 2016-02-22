{ stdenv
, bison
, fetchurl
, gettext
, texinfo

, ncurses
, readline
}:

let
  patchSha256s = import ./patches.nix;
in
with stdenv.lib;
stdenv.mkDerivation rec {
  name = "bash-${version}-p${toString (length (attrNames patchSha256s))}";
  version = "4.3";

  src = fetchurl {
    url = "mirror://gnu/bash/bash-${version}.tar.gz";
    sha256 = "1m14s1f61mf6bijfibcjm9y6pkyvz6gibyl8p4hxq90fisi8gimg";
  };

  # Note: Bison is needed because the patches above modify parse.y.
  nativeBuildInputs = [
    bison
    gettext
    texinfo
  ];

  buildInputs = [
    ncurses
    readline
  ];

  NIX_CFLAGS_COMPILE = [
    "-DSYS_BASHRC=/etc/bashrc"
    "-DSYS_BASH_LOGOUT=/etc/bash_logout"
    "-DDEFAULT_PATH_VALUE=/no-such-path"
    "-DSTANDARD_UTILS_PATH=/no-such-path"
    "-DNON_INTERACTIVE_LOGIN_SHELLS"
    "-DSSH_SOURCE_BASHRC"
  ];

  patchFlags = [
    "-p0"
  ];

  patches = flip mapAttrsToList patchSha256s (name: sha256: fetchurl {
    inherit name sha256;
    url = "mirror://gnu/bash/bash-${version}-patches/${name}";
  });

  configureFlags = [
    "--with-installed-readline=${readline}"
  ];

  postInstall = ''
    ln -s bash "$out/bin/sh"
  '';

  outputs = [ "out" "doc" ];

  passthru = {
    shellPath = "/bin/bash";
  };

  meta = with stdenv.lib; {
    description = "The standard GNU Bourne again shell";
    homepage = http://www.gnu.org/software/bash/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
