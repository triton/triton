{ stdenv
, fetchurl
, gettext
, texinfo

, ncurses
, readline
}:

let
  inherit (stdenv.lib)
    attrNames
    flip
    length
    mapAttrsToList;

  patchSha256s = import ./patches.nix;

  version = "4.4";
in
stdenv.mkDerivation rec {
  name = "bash-${version}-p${toString (length (attrNames patchSha256s))}";

  src = fetchurl {
    url = "mirror://gnu/bash/bash-${version}.tar.gz";
    sha256 = "1jyz6snd63xjn6skk7za6psgidsd53k05cr3lksqybi0q6936syq";
  };

  nativeBuildInputs = [
    gettext
    texinfo
  ];

  buildInputs = [
    ncurses
    readline
  ];

  NIX_CFLAGS_COMPILE = [
    "-DSYS_BASHRC=\"/etc/${passthru.systemBashrcName}\""
    "-DSYS_BASH_LOGOUT=\"/etc/${passthru.systemBashlogoutName}\""
    "-DDEFAULT_PATH_VALUE=\"/no-such-path\""
    "-DSTANDARD_UTILS_PATH=\"/no-such-path\""
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

  # Remove impurities
  preFixup = ''
    rm "$out"/lib/bash/Makefile.inc
  '';

  passthru = {
    shellPath = "/bin/bash";
    systemBashrcName = "bash.bashrc";
    systemBashlogoutName = "bash.bash_logout";
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
