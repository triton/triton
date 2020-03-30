{ stdenv
, fetchurl
}:

let
  version = "2020-03-16";
  version' = stdenv.lib.replaceStrings ["-"] [""] version;
in
stdenv.mkDerivation rec {
  name = "linux-firmware-${version}";

  src = fetchurl {
    url = "mirror://kernel/linux/kernel/firmware/linux-firmware-${version'}.tar.xz";
    sha256 = "7aecb3171a55f5df3e1f02c40ddfcc874cf231d20deae1eeae1ca86404982e82";
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
