{ stdenv
, fetchFromGitHub
, gettext

, ncurses
}:

stdenv.mkDerivation rec {
  name = "vim-${version}";
  version = "7.4.1714";

  src = fetchFromGitHub {
    owner = "vim";
    repo = "vim";
    rev = "v${version}";
    sha256 = "ecdd2b84b2bd3154d57e7acdf57d0263feeaf3507c4402a9fd0bafd6bcb1c753";
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
    ln -s $out/bin/vim $out/bin/vi
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
