{ stdenv
, fetchurl
}:

let
  version = "2019-07-17";
  version' = stdenv.lib.replaceStrings ["-"] [""] version;
in
stdenv.mkDerivation rec {
  name = "linux-firmware-${version}";

  src = fetchurl {
    url = "mirror://kernel/linux/kernel/firmware/linux-firmware-${version'}.tar.xz";
    sha256 = "43175c07d964cc1956b969ffee96c84ca5da622863e83b5521ed4f28a4eaf9d4";
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
