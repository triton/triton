{ stdenv
, fetchTritonPatch
, fetchurl
, gettext
, intltool
, libtool
, makeWrapper

, glib
, gobject-introspection
, polkit
, systemd
, coreutils
}:

with {
  inherit (stdenv.lib)
    enFlag
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "accountsservice-${version}";
  version = "0.6.40";

  src = fetchurl {
    url = "http://www.freedesktop.org/software/accountsservice/${name}.tar.xz";
    sha256 = "0ayb3y3l25dmwxlh9g071h02mphjfbkvi2k5f635bayb01k7akzh";
  };

  patches = [
    (fetchTritonPatch {
      rev = "6f159bbe96eb07e94789b0124fbf7317763633bc";
      file = "accountsservice/no-create-dirs.patch";
      sha256 = "aeea5489710f7aa6abb09bfc4882aeb0a6a93a26bd08f13a81ce415b7944b702";
    })
  ];

  configureFlags = [
    "--enable-admin-group=wheel"
    # Heuristics for guessing system vs human users in the range 500-minimum-uid
    #"--enable-user-heuristics"
    # Set minimum uid for human users
    #"--with-minimum-uid=1000"
    "--disable-coverage"
    "--disable-more-warnings"
    "--disable-docbook-docs"
    (enFlag "systemd" (systemd != null) null)
    (wtFlag "systemdsystemunitdir" (systemd != null) "$(out)/etc/systemd/system")
    "--localstatedir=/var"
  ];

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
    systemd
  ];

  preFixup = ''
    wrapProgram "$out/libexec/accounts-daemon" \
      --run "${coreutils}/bin/mkdir -p /var/lib/AccountsService/users" \
      --run "${coreutils}/bin/mkdir -p /var/lib/AccountsService/icons"
  '';

  meta = with stdenv.lib; {
    description = "D-Bus interface for user account query and manipulation";
    homepage = http://www.freedesktop.org/wiki/Software/AccountsService;
    license = licenses.gpl3;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
