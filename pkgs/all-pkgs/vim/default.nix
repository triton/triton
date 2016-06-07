{ stdenv
, fetchFromGitHub
, gettext

, ncurses
}:

stdenv.mkDerivation rec {
  name = "vim-${version}";
  version = "7.4.1905";

  src = fetchFromGitHub {
    owner = "vim";
    repo = "vim";
    rev = "v${version}";
    sha256 = "59742ccb20507f981bd50e0ecf92615ef8e050d47f7228cf8fd4bec7aec0888b";
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
