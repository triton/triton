{ stdenv
, fetchurl

, kerberos
, libedit
, openssl
, pam
, zlib
}:

stdenv.mkDerivation rec {
  name = "openssh-7.3p1";

  src = fetchurl {
    url = "mirror://openbsd/OpenSSH/portable/${name}.tar.gz";
    hashOutput = false;
    sha256 = "3ffb989a6dcaa69594c3b550d4855a5a2e1718ccdde7f5e36387b424220fbecc";
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

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "59C2 118E D206 D927 E667  EBE3 D3E5 F56B 6D92 0D30";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

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
