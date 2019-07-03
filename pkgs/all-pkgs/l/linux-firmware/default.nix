{ stdenv
, fetchurl
}:

let
  version = "2019-06-18";
  version' = stdenv.lib.replaceStrings ["-"] [""] version;
in
stdenv.mkDerivation rec {
  name = "linux-firmware-${version}";

  src = fetchurl {
    url = "mirror://kernel/linux/kernel/firmware/linux-firmware-${version'}.tar.xz";
    sha256 = "a2f53e47d932e63062188a7b75798e919e659b4e1fbc15272ba8b2c9133e14ac";
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
