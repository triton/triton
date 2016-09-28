{ stdenv
, fetchTritonPatch
, fetchurl

, bzip2
, libnatspec
}:

stdenv.mkDerivation {
  name = "unzip-6.0";

  src = fetchurl {
    url = mirror://sourceforge/infozip/unzip60.tar.gz;
    multihash = "QmXo6yz71MZYwxNcd76XVvjNjP9B8Ngynn5naodRWurAb8";
    sha256 = "0dxx11knh3nk95p2gg2ak777dd11pr7jx5das2g49l262scrcv83";
  };

  buildInputs = [
    bzip2
    libnatspec
  ];

  setupHook = ./setup-hook.sh;

  patches = [
    (fetchTritonPatch {
      rev = "22334bf0aefd6b5bd2107fe1adc484c8f2d467f3";
      file = "u/unzip/unzip-6.0-CVE-2014-8139.patch";
      sha256 = "29c88d94e0dbd829b2712ac038e5af97a15dcb2e3cd62de0a3b43173e0a5d115";
    })
    (fetchTritonPatch {
      rev = "22334bf0aefd6b5bd2107fe1adc484c8f2d467f3";
      file = "u/unzip/unzip-6.0-CVE-2014-8140.patch";
      sha256 = "0b3573a4c633c84c7ca4030c7110b6f2a4bcf94891a9928459d04974e0485c4f";
    })
    (fetchTritonPatch {
      rev = "22334bf0aefd6b5bd2107fe1adc484c8f2d467f3";
      file = "u/unzip/unzip-6.0-CVE-2014-8141.patch";
      sha256 = "af0235ac2fe308540068eb7747ab2afc7cc42e75108738c398999dfc0d949b6a";
    })
    (fetchTritonPatch {
      rev = "22334bf0aefd6b5bd2107fe1adc484c8f2d467f3";
      file = "u/unzip/unzip-6.0-CVE-2014-9636.patch";
      sha256 = "332fd1ff79cac03d1cf93ea80538e6478242ed29e8b35010719a473385123d8d";
    })
    (fetchTritonPatch {
      rev = "22334bf0aefd6b5bd2107fe1adc484c8f2d467f3";
      file = "u/unzip/unzip-6.0-CVE-2015-7696.patch";
      sha256 = "fc6d36383ba9ca35e888912e5f8fd5178ae7e987c78a25816c2c0b60c3b377ba";
    })
    (fetchTritonPatch {
      rev = "22334bf0aefd6b5bd2107fe1adc484c8f2d467f3";
      file = "u/unzip/unzip-6.0-CVE-2015-7697.patch";
      sha256 = "949c05868c47e737f0acd3904287631b5876c0500fa82a4abc334c646356b3f5";
    })
    (fetchTritonPatch {
      rev = "22334bf0aefd6b5bd2107fe1adc484c8f2d467f3";
      file = "u/unzip/unzip-6.0-natspec.patch";
      sha256 = "cf7b6146b034e5687e77c328a9e55efc68ddb75636fdcce84853995ab60082dd";
    })
  ];

  makefile = "unix/Makefile";

  NIX_LDFLAGS = [
    "-lbz2"
    "-lnatspec"
  ];

  buildFlags = "generic D_USE_BZ2=-DUSE_BZIP2 L_BZ2=-lbz2";

  preConfigure = ''
    sed -i  unix/Makefile \
      -e 's@CF="-O3 -Wall -I. -DASM_CRC $(LOC)"@CF="-O3 -Wall -I. -DASM_CRC -DLARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 $(LOC)"@'
  '';

  preInstall = ''
    installFlagsArray+=("prefix=$out")
  '';

  meta = with stdenv.lib; {
    description = "An extraction utility for the zip archive format";
    homepage = http://www.info-zip.org;
    # http://www.info-zip.org/license.html
    license = licenses.free;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
