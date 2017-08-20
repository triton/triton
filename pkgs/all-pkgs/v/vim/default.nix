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

  version = "8.0.0979";
in
stdenv.mkDerivation rec {
  name = "vim-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "vim";
    repo = "vim";
    rev = "v${version}";
    sha256 = "eaf20526772b7d83b3fc2794a6dc663226f6d60bf8caaa08ab5c237483cc26a9";
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
