{ stdenv
, fetchurl

, ncurses
, readline
}:

stdenv.mkDerivation rec {
  name = "unixODBC-2.3.4";

  src = fetchurl {
    url = "ftp://ftp.unixodbc.org/pub/unixODBC/${name}.tar.gz";
    md5Confirm = "bd25d261ca1808c947cb687e2034be81";
    sha256 = "2e1509a96bb18d248bf08ead0d74804957304ff7c6f8b2e5965309c632421e39";
  };

  buildInputs = [
    ncurses
    readline
  ];

  configureFlags = [
    "--disable-gui"
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
