{ stdenv
, fetchurl
, gettext
, intltool
, lib
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
    boolEn
    boolString
    boolWt;
in
stdenv.mkDerivation rec {
  name = "accountsservice-0.6.45";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/accountsservice/${name}.tar.xz";
    multihash = "QmQquttaZYGAEnVWzBpYUwj1WHrddAhDgMW8vt112er15v";
    sha256 = "fb0fc293aa75d59f5ef5db719d37a21831c4dd74a97526ee7e51ce936311ef26";
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

  preConfigure = ''
    configureFlagsArray+=(
      "--${boolWt (systemd_lib != null)}-systemdsystemunitdir${
        boolString (systemd_lib != null) "=$out/etc/systemd/system" ""}"
    )
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-nls"
    "--disable-maintainer-mode"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--enable-admin-group=wheel"
    # Heuristics for guessing system vs human users in the range 500-minimum-uid
    #"--enable-user-heuristics"
    # FIXME: Set minimum uid for human users
    #"--with-minimum-uid=1000"
    "--disable-coverage"
    "--disable-more-warnings"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-docbook-docs"
    "--${boolEn (systemd_lib != null)}-systemd"
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

  meta = with lib; {
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
