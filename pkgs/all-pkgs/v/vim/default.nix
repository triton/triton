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

  version = "8.0.0363";
in

stdenv.mkDerivation rec {
  name = "vim-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "vim";
    repo = "vim";
    rev = "v${version}";
    sha256 = "f6cd55ce0cc9d671abbabeadaf55a4a1a9ad10e2a91f0f10dfe8a74ed4d51d8e";
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
