{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libatomic_ops-7.4.2";

  src = fetchurl {
    url = "http://www.ivmaisoft.com/_bin/atomic_ops/${name}.tar.gz";
    sha256 = "1pdm0h1y7bgkczr8byg20r6bq15m5072cqm5pny4f9crc9gn3yh4";
  };

  meta = with stdenv.lib; {
    description = ''A library for semi-portable access to hardware-provided atomic memory update operations'';
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
