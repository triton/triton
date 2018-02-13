{ stdenv
, fetchurl
, lib

, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "dhcpcd-7.0.1";

  src = fetchurl {
    url = "mirror://roy/dhcpcd/${name}.tar.xz";
    multihash = "QmfXh5tTwgsmMqxf5j1LsoRaqAJu3zAZkWUbsML23aZNQi";
    sha256 = "8b36537fbcc00771b9a6c9ccd71b5011df27b3f892e926b199a195fad2f3f3c8";
  };

  buildInputs = [
    systemd_lib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  # Hack to make installation succeed.  dhcpcd will still use /var/db
  # at runtime.
  preInstall = ''
    installFlagsArray+=(
      "DBDIR=$TMPDIR/db"
      "SYSCONFDIR=$out/etc"
    )
  '';

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
