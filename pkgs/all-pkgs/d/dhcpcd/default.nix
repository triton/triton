{ stdenv
, fetchurl
, lib

, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "dhcpcd-7.0.6";

  src = fetchurl {
    url = "mirror://roy/dhcpcd/${name}.tar.xz";
    multihash = "QmZc8vvowES1xjh8K7kn8UrWhz3vzT1gKv2PAxGLDM43PE";
    sha256 = "727aa7ca972ab45ccad9238ae102604cca94ada87989305d04d81196d78ac341";
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
