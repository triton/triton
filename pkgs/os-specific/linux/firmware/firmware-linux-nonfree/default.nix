{ stdenv
, fetchFromGitHub
}:

let
  version = "2016-08-30";
in
stdenv.mkDerivation rec {
  name = "firmware-linux-nonfree-${version}";

  # This repo is built from
  # http://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git/
  # for any given date. This gives us up to date iwlwifi firmware as well as
  # the usual set of firmware. firmware/linux-firmware usually lags kernel releases
  # so iwlwifi cards will fail to load on newly released kernels.
  src = fetchFromGitHub {
    version = 2;
    owner = "wkennington";
    repo = "linux-firmware";
    rev = "c883a6b6186bb2415761d287cbac773062911212";
    sha256 = "27e5577b9324503413b146858d0d212db20d0b9d6816ea8f0d405545d4b904c6";
  };

  preInstall = ''
    mkdir -p $out
  '';

  installFlags = [
    "DESTDIR=$(out)"
  ];

  passthru = {
    inherit version;
  };

  meta = with stdenv.lib; {
    description = "Binary firmware collection packaged by kernel.org";
    homepage = http://packages.debian.org/sid/firmware-linux-nonfree;
    license = licenses.unfreeRedistributableFirmware;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
    priority = 6; # give precedence to kernel firmware
  };
}
