{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "firmware-linux-nonfree-${version}";
  version = "2016-06-15";

  # This repo is built by merging the latest versions of
  # http://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git/
  # and
  # http://git.kernel.org/cgit/linux/kernel/git/iwlwifi/linux-firmware.git/
  # for any given date. This gives us up to date iwlwifi firmware as well as
  # the usual set of firmware. firmware/linux-firmware usually lags kernel releases
  # so iwlwifi cards will fail to load on newly released kernels.
  src = fetchFromGitHub {
    owner = "wkennington";
    repo = "linux-firmware";
    rev = "9580f45dc5309a88d892605b2527c3905e301add";
    sha256 = "b84743eec589aca6f63c594d986edbd115ab2d84afafea4d113ce45103a66d1a";
  };

  preInstall = ''
    mkdir -p $out
  '';

  installFlags = [ "DESTDIR=$(out)" ];

  meta = with stdenv.lib; {
    description = "Binary firmware collection packaged by kernel.org";
    homepage = http://packages.debian.org/sid/firmware-linux-nonfree;
    license = licenses.unfreeRedistributableFirmware;
    platforms = platforms.linux;
    maintainers = with maintainers; [ wkennington ];
    priority = 6; # give precedence to kernel firmware
  };

  passthru = { inherit version; };
}
