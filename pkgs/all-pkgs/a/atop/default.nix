{ stdenv
, fetchurl

, ncurses
, zlib
}:

stdenv.mkDerivation rec {
  name = "atop-2.4.0";

  src = fetchurl {
    url = "http://www.atoptool.nl/download/${name}.tar.gz";
    multihash = "QmZHZaxpfoYgK2gshBCuwjW9fMDj132YyRaV91AGmNmqca";
    sha256 = "be1c010a77086b7d98376fce96514afcd73c3f20a8d1fe01520899ff69a73d69";
  };

  buildInputs = [
    ncurses
    zlib
  ];

  postPatch = ''
    grep -q 'chown' Makefile
    sed -i 's,chown,true,g' Makefile
  '' + /* Cannot setuid inside of nix-builder */ ''
    sed -i Makefile \
      -e 's/chmod 04711/chmod 0711/'
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
