{ stdenv
, fetchurl

, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "dhcpcd-6.11.1";

  src = fetchurl {
    url = "mirror://roy/dhcpcd/${name}.tar.xz";
    multihash = "Qmd4kPu25tjbTZ4U1ScnTAMYpaaNj84g9rW2dWnpHHdYua";
    sha256 = "1vn6m242ss4plhrs62wyi4j16zv5457calgc2qym3myigrh3v0jw";
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
