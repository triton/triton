{ stdenv
, fetchurl
, lib
, meson
, ninja

, audit_lib
, expat
, libcap-ng
, linux-headers_triton
, libselinux
, systemd_lib
, systemd-dummy
}:

let
  version = "17";
in
stdenv.mkDerivation rec {
  name = "dbus-broker-${version}";

  src = fetchurl {
    url = "https://github.com/bus1/dbus-broker/releases/download/v${version}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "4ec7491745a88ec5112644b0e2b9a0abe9107c85d7650be8988d88efb52da84b";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  buildInputs = [
    audit_lib
    expat
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
