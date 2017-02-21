{ stdenv
, docbook_sgml_dtd_31
, fetchFromGitHub
, perlPackages

, libcap
, libidn
, openssl
, spCompat
}:

let
in
stdenv.mkDerivation rec {
  name = "iputils-2017-01-14";

  src = fetchFromGitHub {
    version = 2;
    owner = "iputils";
    repo = "iputils";
    rev = "3c7b5f7177b62245babe42e1e5b572865186ab7b";
    sha256 = "08136ef95deeb0bcf82227c58917cc1364df42f71c5ed7459458dfdac821bb40";
  };

  postPatch =
  /* Fix expected filename */ ''
    sed -i doc/Makefile \
      -e 's/sgmlspl/sgmlspl.pl/'
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
    docbook_sgml_dtd_31
    perlPackages.SGMLSpm
  ];

  buildInputs = [
    libcap
    libidn
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

  parallelBuild = false;

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
