{ stdenv
, fetchFromGitHub
, gettext

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
  inherit (stdenv.lib)
    optionalString;
in

stdenv.mkDerivation rec {
  name = "vim-${version}";
  version = "7.4.1952";

  src = fetchFromGitHub {
    owner = "vim";
    repo = "vim";
    rev = "v${version}";
    sha256 = "0ab00a31fcf0f7e93f86bb6bab4aa23b67f3ac8b6921f87edcf1ff2062fe34a0";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    ncurses
  ];

  configureFlags = [
    "--enable-multibyte"
    "--enable-nls"
  ];

  postInstall = ''
    ln -sv $out/bin/vim $out/bin/vi
  '' + optionalString (configuration != null) ''
    cat > $out/share/vim/vimrc <<'CONFIGURATION'
    ${configuration}
    CONFIGURATION
  '';

  meta = with stdenv.lib; {
    description = "The most popular clone of the VI editor";
    homepage = http://www.vim.org;
    license = licenses.vim;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
