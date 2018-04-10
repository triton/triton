{ stdenv
, fetchurl
, lib

, alsa-lib
, fftw_single
, libsamplerate
, ncurses
, systemd-dummy
}:

stdenv.mkDerivation rec {
  name = "alsa-utils-1.1.6";

  src = fetchurl {
    url = "mirror://alsa/utils/${name}.tar.bz2";
    multihash = "QmT8tfm2fMu3smutKygap17rgQfdXHRta2udkRcCDzQ3m8";
    sha256 = "155caecc40b2220f686f34ba3655a53e3bdbc0586adb1056733949feaaf7d36e";
  };

  buildInputs = [
    alsa-lib
    fftw_single
    libsamplerate
    ncurses
    systemd-dummy
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-alsatest"  # This is just a test case program
    "--disable-alsaconf"  # Not needed with udev
    "--disable-xmlto"     # Man pages are pre-generated
    "--disable-rst2man"   # Man pages are pre-generated
  ];

  preInstall = ''
    installFlagsArray+=(
      "systemdsystemunitdir=$out/lib/systemd/system"
      "ASOUND_STATE_DIR=$TMPDIR"
    )
  '';

  meta = with lib; {
    description = "ALSA, the Advanced Linux Sound Architecture utils";
    homepage = http://www.alsa-project.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
