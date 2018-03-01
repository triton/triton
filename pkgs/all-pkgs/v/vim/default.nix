{ stdenv
, fetchFromGitHub
, gettext

, acl
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
  inherit (stdenv.lib)
    optionalString;

  version = "8.0.1555";
in
stdenv.mkDerivation rec {
  name = "vim-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "vim";
    repo = "vim";
    rev = "v${version}";
    sha256 = "1d15431b387df96003845b9c89007ff1b88ed81df225043b3203de9fd3f2dcb0";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    acl
    gpm
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
      x86_64-linux;
  };
}
