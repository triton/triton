{ stdenv
, fetchurl

, ncurses
, zlib
}:

stdenv.mkDerivation rec {
  name = "atop-2.3.0";

  src = fetchurl {
    url = "http://www.atoptool.nl/download/${name}.tar.gz";
    multihash = "Qmb8vArZAWV2LaDB6AuoQghi4h1W9CJXVeUiFUZnQo7Lyj";
    sha256 = "73e4725de0bafac8c63b032e8479e2305e3962afbe977ec1abd45f9e104eb264";
  };

  buildInputs = [
    ncurses
    zlib
  ];

  postPatch = ''
    grep -q 'chown' Makefile
    sed -i 's,chown,true,g' Makefile
  '';

  preBuild = ''
    makeFlagsArray+=(
      "BINPATH=$out/bin"
      "SBINPATH=$out/bin"
      "SCRPATH=$out/share/atop"
      "MAN1PATH=$out/share/man/man1"
      "MAN5PATH=$out/share/man/man5"
      "MAN8PATH=$out/share/man/man8"
      "SYSDPATH=$out/lib/systemd/system"
      "PMPATH1=$out/lib/pm-utils/sleep.d"
      "PMPATHD=$out/lib/systemd/system-sleep"
    )
  '';

  preInstall = ''
    installFlagsArray+=(
      "INIPATH=$TMPDIR"
      "CRNPATH=$TMPDIR"
      "LOGPATH=$TMPDIR"
      "ROTPATH=$out/etc/logrotate.d"
    )
  '';

  installTargets = [
    "systemdinstall"
  ];

  meta = with stdenv.lib; {
    description = "Console system performance monitor";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
