{ stdenv
, fetchurl
, lib

, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "dhcpcd-8.1.4";

  src = fetchurl {
    url = "mirror://roy/dhcpcd/${name}.tar.xz";
    multihash = "QmSBoNpV8jRSyzs9MFghvLxM1KzG5eude7oBCU5kc3csQA";
    hashOutput = false;
    sha256 = "27a0d1a37aa1aa23e9d3a906455cf8fd56a83589370dfe9da3c5f3225cc4c13d";
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
