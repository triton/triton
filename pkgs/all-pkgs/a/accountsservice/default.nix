{ stdenv
, fetchurl
, gettext
, lib
, makeWrapper
, meson
, ninja

, coreutils
, dbus-dummy
, glib
, gobject-introspection
, polkit
, systemd-dummy
, systemd_lib
}:

let
  inherit (lib)
    boolEn
    boolString
    boolWt;
in
stdenv.mkDerivation rec {
  name = "accountsservice-0.6.54";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/accountsservice/${name}.tar.xz";
    multihash = "QmXANrKzCRRWo5WDjiWTGtbwArxEEraRqXvJafaFUihhAD";
    sha256 = "26e9062c84797e9604182d0efdb2231cb01c98c3c9b0fea601ca79a2802d21ac";
  };

  nativeBuildInputs = [
    gettext
    makeWrapper
    meson
    ninja
  ];

  buildInputs = [
    dbus-dummy
    glib
    gobject-introspection
    polkit
    systemd-dummy
    systemd_lib
  ];

  postPatch = ''
    grep -q 'meson_post_install.py' meson.build
    sed -i meson.build \
      -e '/add_install_script/,+3 d'
  '' + /* Need to create polkit-dummy instead of this HACK */ ''
    sed -i meson.build \
      -e "s,policy_dir.*$,policy_dir = '$out/share/polkit-1/actions/',"
  '';

  mesonFlags = [
    "-Dlocalstatedir=/var"
    "-Dadmin_group=wheel"
    "-Dsystemd=true"
  ];

  preFixup = ''
    wrapProgram "$out/libexec/accounts-daemon" \
      --run "${coreutils}/bin/mkdir -p /var/lib/AccountsService/icons" \
      --run "${coreutils}/bin/mkdir -p /var/lib/AccountsService/users"
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
