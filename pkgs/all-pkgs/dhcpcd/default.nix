{ stdenv
, fetchurl

, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "dhcpcd-6.11.2";

  src = fetchurl {
    url = "mirror://roy/dhcpcd/${name}.tar.xz";
    multihash = "QmNVFaTvQaWDtDesxnrqPrrjH55CUY5T2sxY1X6eDtxeVG";
    sha256 = "1ahy18s83z0nfy7s5is2bz56xhip09ys2yid2ykjf2jljw5vb7zi";
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
