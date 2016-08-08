{ stdenv
, fetchurl
, gettext
, intltool
, libtool
, makeWrapper

, coreutils
, glib
, gobject-introspection
, polkit
, systemd_lib
}:

let
  inherit (stdenv.lib)
    enFlag
    wtFlag;
in

stdenv.mkDerivation rec {
  name = "accountsservice-0.6.42";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/accountsservice/${name}.tar.xz";
    sha256 = "e56494c2f18627900b57234e5628923cc16a37bf8fd16b06c46118d6ae9c007e";
  };

  nativeBuildInputs = [
    gettext
    intltool
    libtool
    makeWrapper
  ];

  buildInputs = [
    glib
    gobject-introspection
    polkit
    systemd_lib
  ];

  configureFlags = [
    "--enable-admin-group=wheel"
    # Heuristics for guessing system vs human users in the range 500-minimum-uid
    #"--enable-user-heuristics"
    # FIXME: Set minimum uid for human users
    #"--with-minimum-uid=1000"
    "--disable-coverage"
    "--disable-more-warnings"
    "--disable-docbook-docs"
    (enFlag "systemd" (systemd_lib != null) null)
    (wtFlag "systemdsystemunitdir" (systemd_lib != null) "$(out)/etc/systemd/system")
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  preInstall = ''
    installFlagsArray+=(
      "localstatedir=$TMPDIR/var"
      "sysconfdir=$out/etc"
    )
  '';

  preFixup = ''
    wrapProgram "$out/libexec/accounts-daemon" \
      --run "${coreutils}/bin/mkdir -p /var/lib/AccountsService/users" \
      --run "${coreutils}/bin/mkdir -p /var/lib/AccountsService/icons"
  '';

  meta = with stdenv.lib; {
    description = "D-Bus interface for user account query and manipulation";
    homepage = http://www.freedesktop.org/wiki/Software/AccountsService;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
