{ stdenv
, fetchurl
, lib
, meson
, ninja

, audit_lib
, dbus
, expat
, glib
, linux-headers_4-14
, libselinux
, systemd_lib
, systemd-dummy
}:

let
  version = "13";
in
stdenv.mkDerivation rec {
  name = "dbus-broker-${version}";

  src = fetchurl {
    url = "https://github.com/bus1/dbus-broker/releases/download/v${version}/${name}.tar.xz";
    sha256 = "6ac2851d0c7fc985add872439ea5a501d9d7996b7c22315cf5d237f99489335d";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  buildInputs = [
    audit_lib
    expat
    dbus
    glib
    linux-headers_4-14
    libselinux
    systemd_lib
    systemd-dummy
  ];

  postPatch = ''
    # Don't build any tests
    find . -name meson.build -exec sed -i -e "/subdir('test/d" -e '/^[ ]*test/d' {} \;

    # Fix systemd unit dirs
    grep -q "conf.set('systemunitdir'" meson.build
    sed \
      -e "s#conf.set('systemunitdir',.*#conf.set('systemunitdir', '$out/lib/systemd/system')#" \
      -e "s#conf.set('userunitdir',.*#conf.set('userunitdir', '$out/lib/systemd/user')#" \
      -i meson.build
  '';
  
  mesonFlags = [
    "-Daudit=true"
    "-Dselinux=true"
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
