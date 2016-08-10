{ stdenv
, fetchurl

, dbus
, libcap
}:

stdenv.mkDerivation rec {
  name = "rtkit-0.11";
  
  src = fetchurl {
    url = "http://0pointer.de/public/${name}.tar.xz";
    multihash = "QmXaoewTKsfRK6N3PPGdcMKHrDY6eFruUfHwZseD1wkmLQ";
    sha256 = "1l5cb1gp6wgpc9vq6sx021qs6zb0nxg3cn1ba00hjhgnrw4931b8";
  };

  buildInputs = [
    dbus
    libcap
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-systemdsystemunitdir=$out/etc/systemd/system"
    )
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
