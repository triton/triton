{ stdenv
, fetchFromGitHub
}:

let
  version = "2016-06-20";
in
stdenv.mkDerivation rec {
  name = "firmware-linux-nonfree-${version}";

  # This repo is built from
  # http://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git/
  # for any given date. This gives us up to date iwlwifi firmware as well as
  # the usual set of firmware. firmware/linux-firmware usually lags kernel releases
  # so iwlwifi cards will fail to load on newly released kernels.
  src = fetchFromGitHub {
    owner = "wkennington";
    repo = "linux-firmware";
    rev = "dca884016afa9f954baa69e3e28b8f2aab3b6921";
    sha256 = "6e0e061b3a4b2086d55ef58fecaec47650efc4516a1c67d2dc557d3fde52015e";
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
