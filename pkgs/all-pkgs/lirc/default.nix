{ stdenv
, fetchurl
, help2man
, libxslt

, alsa-lib
, portaudio
, python3Packages
, xorg
}:

let
  inherit (stdenv.lib)
    optionals
    wtFlag;
in

# TODO: libirman support
# TODO: irxevent support
# TODO: xmode2 support
# TODO: usb support

assert xorg != null ->
  xorg.libICE != null
  && xorg.libSM != null
  && xorg.libX11 != null;

stdenv.mkDerivation rec {
  name = "lirc-0.9.3a";

  src = fetchurl {
    url = "mirror://sourceforge/lirc/${name}.tar.bz2";
    sha256 = "08pgfsi40d0iq0xwnfkz53whphcnsx8ycxvp65anzd6vrgv0rzws";
  };

  postPatch = ''
    patchShebangs .
  '';

  nativeBuildInputs = [
    help2man
    libxslt
  ];

  buildInputs = [
    alsa-lib
    portaudio
    python3Packages.python
    python3Packages.pyyaml
  ] ++ optionals (xorg != null) [
    xorg.libICE
    xorg.libSM
    xorg.libX11
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-transmitter"
    "--enable-sandboxed"
    "--with-driver=all"
    (wtFlag "x" (xorg != null) null)
  ];

  makeFlags = [
    "m4dir=$(out)/m4"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "localstatedir=$TMPDIR"
    )
  '';

  parallelBuild = false;

  meta = with stdenv.lib; {
    description = "Allows to receive and send infrared signals";
    homepage = http://www.lirc.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
