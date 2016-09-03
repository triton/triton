{ stdenv
, fetchFromGitHub
}:

let
  version = "2016-08-14";
in
stdenv.mkDerivation rec {
  name = "firmware-linux-nonfree-${version}";

  # This repo is built from
  # http://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git/
  # for any given date. This gives us up to date iwlwifi firmware as well as
  # the usual set of firmware. firmware/linux-firmware usually lags kernel releases
  # so iwlwifi cards will fail to load on newly released kernels.
  src = fetchFromGitHub {
    version = 1;
    owner = "wkennington";
    repo = "linux-firmware";
    rev = "70a3c2adcce7c51e4f26e929d666237904f6fd31";
    sha256 = "c71f5d142276dc7775f547f89d92b12a5072462bc64be9da461b7ddc78d213e5";
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
