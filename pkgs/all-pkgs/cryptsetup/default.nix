{ stdenv
, fetchurl
, lvm2
, openssl
, libutil-linux
, popt
, python
}:

stdenv.mkDerivation rec {
  name = "cryptsetup-1.7.0";

  src = fetchurl {
    url = "mirror://kernel/linux/utils/cryptsetup/v1.7/${name}.tar.xz";
    sha256 = "0j6iwf64pdrl4nm5ypc2r33b3k0aflb939wz2496vcqdrjkj8m87";
  };

  configureFlags = [
    "--enable-cryptsetup-reencrypt"
    "--with-crypto_backend=openssl"
    "--enable-python"
  ];

  buildInputs = [
    lvm2
    openssl
    libutil-linux
    popt
    python
  ];

  meta = {
    homepage = http://code.google.com/p/cryptsetup/;
    description = "LUKS for dm-crypt";
    license = stdenv.lib.licenses.gpl2;
    maintainers = with stdenv.lib.maintainers; [ viric chaoflow ];
    platforms = with stdenv.lib.platforms; linux;
  };
}
