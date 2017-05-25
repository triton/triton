{ stdenv
, fetchurl

, alsa-lib
, pulseaudio_lib
, xorg
}:

stdenv.mkDerivation rec {
  name = "libao-1.2.0";

  src = fetchurl {
    url = "mirror://xiph/ao/${name}.tar.gz";
    multihash = "QmQGVMEhh5eEhJc5tQFWcDZzNf9rMwLrQxqWLVwqDtEwYo";
    hashOutput = false;  # Hashes are at https://xiph.org/downloads/
    sha256 = "03ad231ad1f9d64b52474392d63c31197b0bc7bd416e58b1c10a329a5ed89caf";
  };

  buildInputs = [
    alsa-lib
    pulseaudio_lib
    xorg.libICE
    xorg.libX11
    xorg.libXau
    xorg.xproto
  ];

  meta = with stdenv.lib; {
    homepage = http://xiph.org/ao/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
