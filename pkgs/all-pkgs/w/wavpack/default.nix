{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "wavpack-5.0.0";

  src = fetchurl {
    url = "http://www.wavpack.com/${name}.tar.bz2";
    multihash = "QmRXZ8PkXwe6pUUgdfY7bNE9MQVvUv4i1pu8LmEFFzpN9S";
    sha256 = "918d7e32a19598df543b17fff840b10a0880f87296f9e32af454d256b6a64049";
  };

  meta = with stdenv.lib; {
    description = "Hybrid audio compression format";
    homepage = http://www.wavpack.com/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
