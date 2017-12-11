{ stdenv
, fetchurl

, json-c
, libargon2
, lvm2
, openssl
, popt
, python
, util-linux_lib
}:

let
  major = "2.0";
  patch = "0";

  version = "${major}.${patch}";

  baseUrl = "mirror://kernel/linux/utils/cryptsetup/v${major}";
in
stdenv.mkDerivation rec {
  name = "cryptsetup-${version}";

  src = fetchurl {
    url = "${baseUrl}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "adc623b9e3e3ab5c14145b8baf21b741e513ee5bf90d2b4d85a745c2f05da199";
  };

  buildInputs = [
    json-c
    libargon2
    lvm2
    openssl
    popt
    python
    util-linux_lib
  ];

  configureFlags = [
    "--enable-libargon2"
    "--enable-python"
    "--with-crypto_backend=openssl"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrl = "${baseUrl}/${name}.tar.sign";
      pgpDecompress = true;
      pgpKeyFingerprint = "2A29 1824 3FDE 4664 8D06  86F9 D9B0 577B D93E 98FC";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "LUKS for dm-crypt";
    homepage = http://code.google.com/p/cryptsetup/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
