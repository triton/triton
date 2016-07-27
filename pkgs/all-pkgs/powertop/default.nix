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

stdenv.mkDerivation rec {
  name = "powertop-2.8";

  src = fetchurl {
    url = "https://01.org/sites/default/files/downloads/powertop/${name}.tar.gz";
    sha256 = "a87b563f73106babfa3e74dcf92f252938c061e309ace20a361358bbfa579c5a";
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
