{ stdenv
, fetchurl
, lib

, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "dhcpcd-7.2.3";

  src = fetchurl {
    url = "mirror://roy/dhcpcd/${name}.tar.xz";
    multihash = "QmWAQnehKdfWnf6bbg4h2Q59QKYup27ftHWVF6wuPadvFT";
    hashOutput = false;
    sha256 = "74ab38177548abe968c2abacefffdd97b573acaedd4f77b6c0a54ae38f68566e";
  };

  buildInputs = [
    systemd_lib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  preInstall = ''
    installFlagsArray+=(
      "DBDIR=$TMPDIR/db"
      "SYSCONFDIR=$out/etc"
    )
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Urls = map (n: "${n}.distinfo.asc") src.urls;
        pgpKeyFingerprint = "A785 ED27 5595 5D9E 93EA 59F6 597F 97EA 9AD4 5549";
      };
    };
  };

  meta = with lib; {
    description = "A client for the Dynamic Host Configuration Protocol (DHCP)";
    homepage = http://roy.marples.name/projects/dhcpcd;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
