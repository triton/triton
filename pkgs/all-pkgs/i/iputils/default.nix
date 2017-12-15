{ stdenv
, docbook-xsl
, docbook_sgml_dtd_31
, fetchFromGitHub
, libxslt
, perlPackages

, libcap
, libidn2
, openssl
, spCompat
}:

let
in
stdenv.mkDerivation rec {
  name = "iputils-2017-11-01";

  src = fetchFromGitHub {
    version = 3;
    owner = "iputils";
    repo = "iputils";
    rev = "b551fb608a1314fce824ca5a437e5381b7bbf95c";
    sha256 = "578bb59b7db799aa1d770d431bef6cf27823f53776a35a9980e261a20cb6af94";
  };

  postPatch = /* Fix hardcoded xsltproc path */ ''
    sed -i doc/Makefile \
      -e 's,/usr/bin/,,'
  '';

  makeFlags = [
    "LIBC_INCLUDE=${stdenv.cc.libc}/include"
    "USE_CAP=yes"
    "USE_SYSFS=no" # Deprecated
    "USE_IDN=yes" # Experimental
    "WITHOUT_IFADDRS=no"
    "USE_NETTLE=no"
    "USE_GCRYPT=no"
    "USE_CRYPTO=shared"
    "USE_RESOLV=yes"
    "ENABLE_PING6_RTHDR=no" # Deprecated
    "ENABLE_RDISC_SERVER=no"
  ];

  nativeBuildInputs = [
    docbook-xsl
    libxslt
  ];

  buildInputs = [
    libcap
    libidn2
    openssl
    spCompat
  ];

  buildFlags = [
    "all"
    "man"
    "ninfod"
  ];

  installPhase = ''
    runHook 'preInstall'
  '' +
  /* iputils does not provide a make install target */ ''
    install -vDm 755 ping $out/bin/ping
    ln -sv $out/bin/ping $out/bin/ping6
    install -vDm 755 tracepath $out/bin/tracepath
    install -vDm 755 clockdiff $out/bin/clockdiff
    install -vDm 755 arping $out/bin/arping
    install -vDm 755 rdisc $out/bin/rdisc
    install -vDm 755 ninfod/ninfod $out/bin/ninfod
    install -vDm 755 traceroute6 $out/bin/traceroute6
    install -vDm 755 tftpd $out/bin/tftpd
    install -vDm 755 rarpd $out/bin/rarpd

    install -vDm 644 doc/ping.8 $out/share/man/man8/ping.8
    install -vDm 644 doc/tracepath.8 $out/share/man/man8/tracepath.8
    install -vDm 644 doc/clockdiff.8 $out/share/man/man8/clockdiff.8
    install -vDm 644 doc/arping.8 $out/share/man/man8/arping.8
    install -vDm 644 doc/rdisc.8 $out/share/man/man8/rdisc.8
    install -vDm 644 doc/ninfod.8 $out/share/man/man8/ninfod.8
    install -vDm 644 doc/traceroute6.8 $out/share/man/man8/traceroute6.8
    install -vDm 644 doc/tftpd.8 $out/share/man/man8/tftpd.8
    install -vDm 644 doc/rarpd.8 $out/share/man/man8/rarpd.8
  '' + ''
    runHook 'postInstall'
  '';

  buildParallel = false;

  meta = with stdenv.lib; {
    description = "Network monitoring tools including ping and ping6";
    homepage = http://www.skbuff.net/iputils/;
    license = licenses.bsdOriginal;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
