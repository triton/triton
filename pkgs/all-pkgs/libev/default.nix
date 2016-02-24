{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libev-4.22";

  src = fetchurl {
    urls = [
      "http://dist.schmorp.de/libev/Attic/${name}.tar.gz"
      "http://download.openpkg.org/components/cache/libev/${name}.tar.gz"
    ];
    sha256 = "1mhvy38g9947bbr0n0hzc34zwfvvfd99qgzpkbap8g2lmkl7jq3k";
  };

  meta = with stdenv.lib; {
    description = "A high-performance event loop/event model with lots of features";
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
