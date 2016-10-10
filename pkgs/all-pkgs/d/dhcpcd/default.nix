{ stdenv
, fetchurl

, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "dhcpcd-6.11.5";

  src = fetchurl {
    url = "mirror://roy/dhcpcd/${name}.tar.xz";
    multihash = "QmfXh5tTwgsmMqxf5j1LsoRaqAJu3zAZkWUbsML23aZNQi";
    sha256 = "6f9674dc7e27e936cc787175404a6171618675ecfb6903ab9887b1b66a87d69e";
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

  meta = with stdenv.lib; {
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
