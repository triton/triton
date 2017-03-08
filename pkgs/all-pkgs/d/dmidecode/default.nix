{ stdenv
, fetchzip
}:

let
  date = "2017-01-20";
  rev = "adbd050d70b6173dd6880b21fd6f995af5ea79d2";
in
stdenv.mkDerivation rec {
  name = "dmidecode-${date}";

  src = fetchzip {
    version = 2;
    url = "https://git.savannah.nongnu.org/cgit/dmidecode.git/snapshot/dmidecode-${rev}.tar.xz";
    multihash = "QmfRA9HrdFLo5T9xivwiejn6wpi7YKdpjvawgvHqqeKwVG";
    sha256 = "2bbea761bf3e4b6b0605bded87532eb6080cdb0f063089ced7ad9af64d8447c1";
  };

  preBuild = ''
    makeFlagsArray+=("prefix=$out")
  '';

  meta = with stdenv.lib; {
    description = "Gathers hardware information from the BIOS via the SMBIOS/DMI standard";
    homepage = http://www.nongnu.org/dmidecode/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
