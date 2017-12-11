{ stdenv
, fetchurl
}:

let
  version = "2017-12-10";
in
stdenv.mkDerivation rec {
  name = "linux-firmware-${version}";

  # This repo is built from
  # http://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git/
  # for any given date. This gives us up to date iwlwifi firmware as well as
  # the usual set of firmware. firmware/linux-firmware usually lags kernel releases
  # so iwlwifi cards will fail to load on newly released kernels.
  src = fetchurl {
    url = "https://github.com/wkennington/linux-firmware/releases/download/${version}/${name}.tar.xz";
    sha256 = "391e29830e29e28136f042de4e69961c01311bd20f0e69aaf9269a9cbedaf46e";
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
    license = licenses.unfreeRedistributableFirmware;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
    priority = 6; # give precedence to kernel firmware
  };
}
