{ stdenv
, autoreconfHook
, fetchFromGitHub
, help2man
, lib

, bzip2
, corosync
, dbus
, getopt
, glib
, gnutls
, libqb
, libxml2
, libxslt
, ncurses
, pam
, systemd-dummy
, util-linux_lib
}:

let
  version = "2.0.0";
in
stdenv.mkDerivation rec {
  name = "pacemaker-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "ClusterLabs";
    repo = "pacemaker";
    rev = "Pacemaker-${version}";
    sha256 = "1ceb03dc6aba1a76125ee591d4342529d796f772cbe70903b2571bc39bcd14b6";
  };

  nativeBuildInputs = [
    autoreconfHook
    # Man page generation require scripts to be run
    #help2man
    libxslt
  ];

  buildInputs = [
    bzip2
    corosync
    dbus
    getopt
    glib
    gnutls
    libqb
    libxml2
    libxslt
    ncurses
    pam
    systemd-dummy
    util-linux_lib
  ];

  postPatch = ''
    # Don't compile in extra debug info
    grep -q '\-ggdb' configure.ac
    sed -i 's, -ggdb,,g' configure.ac

    # Correct the ocf path
    grep -q '/usr/lib/ocf' configure.ac
    sed -i 's#/usr/lib/ocf#/run/current-system/sw/lib/ocf#g' configure.ac

    # Don't chown to users / groups in the install path
    grep -q '\-chown ' Makefile.am daemons/schedulerd/Makefile.am
    sed -i '/-ch\(own\|grp\|mod\)/d' Makefile.am daemons/schedulerd/Makefile.am

    # Don't make directories with specific permissions
    grep -q '$(INSTALL) -d' Makefile.am
    sed -i '/$(INSTALL) -d/d' Makefile.am

    # Don't build the test suite
    grep -q ' cts' Makefile.am
    sed -i 's, cts,,g' Makefile.am
    grep -q 'AM_PATH_PYTHON' configure.ac
    sed -i '/AM_PATH_PYTHON/d' configure.ac

    # Don't build legacy python scripts
    grep -q 'fence_legacy' daemons/fenced/Makefile.am
    sed -i '/fence_legacy/d' daemons/fenced/Makefile.am
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-upstart"
    "--enable-systemd"
    "--enable-hardening"
    "--disable-legacy-links"
    "--with-corosync"
    "--with-acl"
    "--with-cibsecrets"
  ];

  preInstall = ''
    installFlagsArray+=(
      "PE_STATE_DIR=$TMPDIR"
      "systemdunitdir=$out/lib/systemd/system"
      "ocfdir=$out/lib/ocf/resource.d/pacemaker"
      "OCF_RA_DIR=$out/lib/ocf/resource.d"
      "OCF_ROOT_DIR=$out/lib/ocf"
      "logrotatedir=$out/etc/logrotate.d"
    )
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
