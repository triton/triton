{ stdenv
, fetchurl

, dbus
, libcap
, systemd_lib
, systemd-dummy
}:

let
  version = "0.12";
in
stdenv.mkDerivation rec {
  name = "rtkit-${version}";
  
  src = fetchurl {
    url = "https://github.com/heftig/rtkit/releases/download/v${version}/${name}.tar.xz";
    sha256 = "d2e724b41b51ea9003ef18ccfe47e6f18e5f6d96d80c9e6b6d2026d7e2c78f10";
  };

  buildInputs = [
    dbus
    libcap
    systemd_lib
    systemd-dummy
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  preFixup = ''
    rm -r "$out"/libexec/installed-tests
  '';

  meta = with stdenv.lib; {
    homepage = http://0pointer.de/blog/projects/rtkit;
    descriptions = "A daemon that hands out real-time priority to processes";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
