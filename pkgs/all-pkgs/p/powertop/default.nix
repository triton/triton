{ stdenv
, fetchurl

, bluez
, kmod
, libnl
, ncurses
, pciutils
, util-linux_full
, xorg
}:

let
  version = "2.9";
in
stdenv.mkDerivation rec {
  name = "powertop-${version}";

  src = fetchurl {
    url = "https://01.org/sites/default/files/downloads/powertop/powertop-v${version}.tar.gz";
    multihash = "QmYKHfQHNrZKhe9wTn95QQUNiGqsmQmWVXHEDw9FhEBXJV";
    sha256 = "aa7fb7d8e9a00f05e7d8a7a2866d85929741e0d03a5bf40cab22d2021c959250";
  };

  buildInputs = [
    bluez
    kmod
    libnl
    ncurses
    pciutils
    util-linux_full
    xorg.xset
  ];

  postPatch = ''
    sed -i "s,/usr/bin/xset,$(type -tP xset),g" src/calibrate/calibrate.cpp
    sed \
      -e "s,/usr/bin/hcitool,$(type -tP hcitool),g" \
      -e "s,/usr/sbin/hciconfig,$(type -tP hciconfig),g" \
      -i src/tuning/bluetooth.cpp
    sed \
      -e "s,/bin/mount,$(type -tP mount),g" \
      -e "s,/sbin/modprobe,$(type -tP modprobe),g" \
      -i src/main.cpp
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
