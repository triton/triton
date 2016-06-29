{ stdenv
, fetchFromGitHub
}:

let
  version = "2016-06-25";
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
    rev = "3ef7857d511ce6a91c5ce609da76c4702651cfa5";
    sha256 = "c02809f67e4f59e97e78763b9a95021d267334110122603848ed160f97d8abab";
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
