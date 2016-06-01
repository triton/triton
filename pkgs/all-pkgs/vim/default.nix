{ stdenv
, fetchFromGitHub
, gettext

, ncurses
}:

stdenv.mkDerivation rec {
  name = "vim-${version}";
  version = "7.4.1868";

  src = fetchFromGitHub {
    owner = "vim";
    repo = "vim";
    rev = "v${version}";
    sha256 = "d02fab86ee50212fdbac268c07bf747c97d33b021e0ef98e82541ebf9dab66c5";
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
