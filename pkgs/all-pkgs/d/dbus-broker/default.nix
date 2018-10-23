{ stdenv
, fetchurl
, lib
, meson
, ninja

, audit_lib
, dbus
, expat
, glib
, libcap-ng
, linux-headers_triton
, libselinux
, systemd_lib
, systemd-dummy
}:

let
  version = "16";
in
stdenv.mkDerivation rec {
  name = "dbus-broker-${version}";

  src = fetchurl {
    url = "https://github.com/bus1/dbus-broker/releases/download/v${version}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "5c0c5d01e521852c08fda6de156e2e56a38ba999ca214ec8064c2d067a8a5d03";
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
    libcap-ng
    linux-headers_triton
    libselinux
    systemd_lib
    systemd-dummy
  ];

  postPatch = ''
    # Don't build any tests
    grep -q -r "subdir('test" --include meson.build .
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

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = { };
    };
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
