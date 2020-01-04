{ stdenv
, fetchFromGitHub
, gettext
, lib

, acl
, attr
, gpm
, ncurses

, configuration ? ''
  " Disable vi compatibility if progname ends in `vim`
  "   e.g. vim or gvim
  if v:progname =~? 'vim''$'
    set nocompatible
  endif
''
}:

let
  inherit (lib)
    optionalString;

  version = "8.2.0083";
in
stdenv.mkDerivation rec {
  name = "vim-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "vim";
    repo = "vim";
    rev = "v${version}";
    sha256 = "68ef4ed69cb68740d01cc01f77c1f7cd748515cd4b10126b8d64321badf9cb88";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    acl
    attr
    gpm
    ncurses
  ];

  configureFlags = [
    "--enable-fail-if-missing"
    "--enable-multibyte"
  ];

  postInstall = ''
    ln -sv $out/bin/vim $out/bin/vi
  '' + optionalString (configuration != null) ''
    cat > $out/share/vim/vimrc <<'CONFIGURATION'
    ${configuration}
    CONFIGURATION
  '';

  meta = with lib; {
    description = "The most popular clone of the VI editor";
    homepage = http://www.vim.org;
    license = licenses.vim;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
