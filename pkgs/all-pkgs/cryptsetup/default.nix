{ stdenv
, fetchurl

, lvm2
, openssl
, popt
, python
, util-linux_lib
}:

stdenv.mkDerivation rec {
  name = "cryptsetup-1.7.1";

  src = fetchurl {
    url = "mirror://kernel/linux/utils/cryptsetup/v1.7/${name}.tar.xz";
    sha256 = "1v0zj4181ahckn5hn95kg3zbqw944raz769wdam5cjwqriiqmp3k";
  };

  buildInputs = [
    lvm2
    openssl
    popt
    python
    util-linux_lib
  ];

  configureFlags = [
    "--enable-cryptsetup-reencrypt"
    "--with-crypto_backend=openssl"
    "--enable-python"
  ];

  meta = with stdenv.lib; {
    description = "LUKS for dm-crypt";
    homepage = http://code.google.com/p/cryptsetup/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
