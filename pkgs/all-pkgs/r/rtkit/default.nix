{ stdenv
, fetchurl
, fetchTritonPatch

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

  patches = [
    (fetchTritonPatch {
      rev = "8b421ec0c7ae98deb1f1cf79fe6e100ee92e047a";
      file = "r/rtkit/SECURITY-pass-uid-of-caller-to-polkit.patch";
      sha256 = "50dd1740add5896cad7fbcfc7d825599c9c66054e46449d6a81041988eb707e7";
    })
  ];

  buildInputs = [
    dbus
    libcap
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-systemdsystemunitdir=$out/etc/systemd/system"
    )
  '';

  # FIXME
  NIX_LDFLAGS = [
    "-lrt"
  ];

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
