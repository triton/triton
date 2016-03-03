{ stdenv
, fetchFromGitHub
, gettext

, ncurses
}:

stdenv.mkDerivation rec {
  name = "vim-${version}";
  version = "7.4.1485";

  src = fetchFromGitHub {
    owner = "vim";
    repo = "vim";
    rev = "v${version}";
    sha256 = "1chm8n4lw7sn0jvn3jk11qpk820rf81kika1a3rn9ickkz76liqk";
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
