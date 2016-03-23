{ stdenv
, bison
, fetchurl
, flex

, dbus
, libnl
, libusb
}:

stdenv.mkDerivation rec {
  name = "libpcap-1.7.4";

  src = fetchurl {
    url = "http://www.tcpdump.org/release/${name}.tar.gz";
    sha256 = "1c28ykkizd7jqgzrfkg7ivqjlqs9p6lygp26bsw2i0z8hwhi3lvs";
  };

  nativeBuildInputs = [
    flex
    bison
  ];

  buildInputs = [
    dbus
    libnl
    libusb
  ];
  
  configureFlags = [
    "--with-pcap=linux"
    "--with-libnl"
    "--enable-ipv6"
    "--enable-shared"
    "--enable-usb"
    "--disable-bluetooth"  # TODO: I think this needs newer headers
    "--enable-canusb"
    "--enable-can"
    "--enable-dbus"
  ];

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I$(echo "${libnl}"/include/*)"
  '';

  meta = with stdenv.lib; {
    homepage = http://www.tcpdump.org;
    description = "Packet Capture Library";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
