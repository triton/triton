{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libsmi-0.5.0";

  src = fetchurl {
    url = "https://www.ibr.cs.tu-bs.de/projects/libsmi/download/${name}.tar.gz";
    multihash = "QmW4Z21ScDXN79MQ6aj8gweHdvgcsunmADWpHBiw3Ftiq8";
    sha256 = "f21accdadb1bb328ea3f8a13fc34d715baac6e2db66065898346322c725754d3";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
