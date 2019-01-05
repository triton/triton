{ stdenv
, fetchurl
, lib

, json-c
, libargon2
, lvm2
, openssl
, popt
, systemd-dummy
, util-linux_lib
}:

let
  channel = "2.0";
  version = "${channel}.6";

  baseUrl = "mirror://kernel/linux/utils/cryptsetup/v${channel}";
in
stdenv.mkDerivation rec {
  name = "cryptsetup-${version}";

  src = fetchurl {
    url = "${baseUrl}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "7c51fae0f0e7ea9af0f515b2ac77009fb2969a6619ebab47d097dca38b083d30";
  };

  buildInputs = [
    json-c
    libargon2
    lvm2
    openssl
    popt
    systemd-dummy
    util-linux_lib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-libargon2"
    "--with-crypto_backend=openssl"
  ];

  preInstall = ''
    installFlagsArray+=(
      "tmpfilesddir=$out/lib/tmpfiles.d"
    )
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpDecompress = true;
        pgpsigUrl = "${baseUrl}/${name}.tar.sign";
        pgpKeyFingerprint = "2A29 1824 3FDE 4664 8D06  86F9 D9B0 577B D93E 98FC";
      };
    };
  };

  meta = with lib; {
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
