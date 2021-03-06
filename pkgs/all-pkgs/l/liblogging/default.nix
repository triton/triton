{ stdenv
, fetchurl

, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "liblogging-1.0.5";

  src = fetchurl {
    url = "http://download.rsyslog.com/liblogging/${name}.tar.gz";
    sha256 = "02w94j344q0ywlj4mdf9fnzwggdsn3j1yn43sdlsddvr29lw239i";
  };

  buildInputs = [
    systemd_lib
  ];

  configureFlags = [
    "--enable-rfc3195"
    "--enable-stdlog"
    "--enable-journal"
    "--enable-man-pages"
  ];

  meta = with stdenv.lib; {
    homepage = http://www.liblogging.org/;
    description = "Lightweight signal-safe logging library";
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
