{ stdenv
, fetchurl
}:

let
  version = "2019-05-14";
  version' = stdenv.lib.replaceStrings ["-"] [""] version;
in
stdenv.mkDerivation rec {
  name = "linux-firmware-${version}";

  src = fetchurl {
    url = "mirror://kernel/linux/kernel/firmware/linux-firmware-${version'}.tar.xz";
    sha256 = "56d40b8f906fe430de9aecf1caee9a4b778783e04d35432a0f1eb21d08966247";
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
