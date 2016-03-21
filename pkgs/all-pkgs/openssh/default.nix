{ stdenv
, fetchurl

, kerberos
, libedit
, openssl
, pam
, zlib
}:

stdenv.mkDerivation rec {
  name = "openssh-7.2p2";

  src = fetchurl {
    url = "mirror://openbsd/OpenSSH/portable/${name}.tar.gz";
    sha256 = "132lh9aanb0wkisji1d6cmsxi520m8nh7c7i9wi6m1s3l38q29x7";
  };

  patches = [
    ./locale_archive.patch
  ];

  buildInputs = [
    kerberos
    libedit
    openssl
    pam
    zlib
  ];

  # I set --disable-strip because later we strip anyway. And it fails to strip
  # properly when cross building.
  configureFlags = [
    "--localstatedir=/var"
    "--with-pid-dir=/run"
    "--with-mantype=man"
    "--with-libedit=yes"
    "--disable-strip"
    "--with-pam"
    "--sysconfdir=/etc/ssh"
    "--with-kerberos5=${kerberos}"
  ];

  preConfigure = ''
    configureFlagsArray+=("--with-privsep-path=$out/empty")
    mkdir -p $out/empty
  '';

  preInstall = ''
    installFlagsArray+=("sysconfdir=$out/etc/ssh")
  '';

  installTargets = [
    "install-nokeys"
  ];

  meta = with stdenv.lib; {
    homepage = "http://www.openssh.org/";
    description = "An implementation of the SSH protocol";
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
