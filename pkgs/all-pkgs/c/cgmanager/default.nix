{ stdenv
, fetchurl

, dbus
, libnih
, pam
}:

stdenv.mkDerivation rec {
  name = "cgmanager-0.41";

  src = fetchurl {
    url = "https://linuxcontainers.org/downloads/cgmanager/${name}.tar.gz";
    multihash = "QmYgy5r18amgq86xw9UjZuk8MooPfjqXuQtdw9Zvwf1cYm";
    hashOutput = false;
    sha256 = "29b155befb3ac233d5d29dbca7c791c8138bab01bfa78ea4757ebb88ce23b458";
  };

  buildInputs = [
    dbus
    libnih
    pam
  ];

  configureFlags = [
    "--with-init-script=systemd"
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "F1D0 8DB7 7818 5BF7 8400  2DFF E9FE EA06 A85E 3F9D";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "A central privileged daemon that manages all your cgroups";
    homepage = https://linuxcontainers.org/cgmanager/introduction/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
