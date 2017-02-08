{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "wavpack-5.1.0";

  src = fetchurl {
    url = "http://www.wavpack.com/${name}.tar.bz2";
    multihash = "QmVnbbB76TwzqZjdDxeG3pLvE5mbfcnQSXyACCJwbL9EwZ";
    sha256 = "1939627d5358d1da62bc6158d63f7ed12905552f3a799c799ee90296a7612944";
  };

  meta = with lib; {
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
