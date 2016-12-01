{ stdenv
, fetchurl
, help2man
, libxslt
, python3Packages

, alsa-lib
, libftdi
, libusb-compat
, linux-headers
, portaudio
, systemd_lib
, xorg
}:

let
  inherit (stdenv.lib)
    optionals
    wtFlag;

  version = "0.9.4c";
in

# TODO: libirman support
# TODO: irxevent support
# TODO: xmode2 support
# TODO: usb support

stdenv.mkDerivation rec {
  name = "lirc-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/lirc/LIRC/${version}/${name}.tar.bz2";
    sha256 = "8974fe5dc8eaa717daab6785d2aefeec27615f01ec24b96d31e3381b2f70726a";
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
    libusb-compat
    linux-headers
    portaudio
    systemd_lib
    xorg.libICE
    xorg.libSM
    xorg.libX11
  ];

  postPatch = ''
    patchShebangs .
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

  parallelBuild = false;

  meta = with stdenv.lib; {
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
