{ stdenv
, fetchurl
, help2man
, lib
, libxslt
, python3Packages

, alsa-lib
, libftdi
, libice
, libsm
, libx11
, libusb-compat
, linux-headers
, portaudio
, systemd_lib
, xorg
}:

# TODO: libirman support
# TODO: irxevent support
# TODO: xmode2 support
# TODO: usb support

let
  version = "0.10.1";
in
stdenv.mkDerivation rec {
  name = "lirc-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/lirc/LIRC/${version}/${name}.tar.bz2";
    sha256 = "8b753c60df2a7f5dcda2db72c38e448ca300c3b4f6000c1501fcb0bd5df414f2";
  };

  nativeBuildInputs = [
    help2man
    libxslt
    python3Packages.python
    python3Packages.pyyaml
  ];

  buildInputs = [
    alsa-lib
    libftdi
    libice
    libsm
    libusb-compat
    libx11
    linux-headers
    portaudio
    systemd_lib
  ];

  postPatch = ''
    patchShebangs .
    sed -i 's,^PYTHONPATH *=,PYTHONPATH := $(PYTHONPATH):,' \
      Makefile.in
    sed -i "s,PYTHONPATH=,PYTHONPATH=$(toPythonPath ${python3Packages.pyyaml}):," \
      doc/Makefile.in
    sed -i "s,/usr/include/linux,${linux-headers}/include/linux,g" \
      tools/lirc-make-devinput
    sed -i 's,/usr/bin/false,false,' configure
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-x"
  ];

  preBuild = ''
    makeFlagsArray+=(
      "m4dir=$out/share/m4"
    )
  '';

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "localstatedir=$TMPDIR"
      "systemdsystemunitdir=$out/lib/systemd/system"
    )
  '';

  preFixup = ''
    sed -i '/#include "config.h"/d' "$out/include/lirc/curl_poll.h"
  '';

  meta = with lib; {
    description = "Allows to receive and send infrared signals";
    homepage = http://www.lirc.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
