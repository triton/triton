{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libev-4.22";

  src = fetchurl {
    urls = [
      "mirror://gentoo/distfiles/${name}.tar.gz"
      "http://dist.schmorp.de/libev/Attic/${name}.tar.gz"
    ];
    multihash = "QmPcmhWko3gMDNEdYxSkWD3HZnTT4Rj562hfv1zwpZbTSN";
    sha256 = "1mhvy38g9947bbr0n0hzc34zwfvvfd99qgzpkbap8g2lmkl7jq3k";
  };

  meta = with stdenv.lib; {
    description = "A high-performance event loop/event model with lots of features";
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
