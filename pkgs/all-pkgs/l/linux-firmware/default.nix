{ stdenv
, fetchurl
}:

let
  version = "2019-10-22";
  version' = stdenv.lib.replaceStrings ["-"] [""] version;
in
stdenv.mkDerivation rec {
  name = "linux-firmware-${version}";

  src = fetchurl {
    url = "mirror://kernel/linux/kernel/firmware/linux-firmware-${version'}.tar.xz";
    sha256 = "4a6b5a14cec91c552b57fa0a29759851f015b981f73a25e192cab8bb39f2f977";
  };

  preInstall = ''
    mkdir -p $out
  '';

  installFlags = [
    "DESTDIR=$(out)"
  ];

  dontStrip = true;
  dontPatchShebangs = true;
  dontPatchELF = true;

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
