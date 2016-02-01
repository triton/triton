{ stdenv
, docbook_sgml_dtd_31
, fetchTritonPatch
, fetchurl
, perlPackages

, libcap
, libgcrypt
, libidn
, nettle
, openssl
, spCompat
}:

# Requires glibc
assert stdenv.cc.isGNU;
assert stdenv.isLinux;

stdenv.mkDerivation rec {
  name = "iputils-${version}";
  version = "20151218";

  src = fetchurl {
    url = "http://www.skbuff.net/iputils/iputils-s${version}.tar.bz2";
    sha256 = "189592jlkhxdgy8jc07m4bsl41ik9r6i6aaqb532prai37bmi7sl";
  };

  patches = [
    (fetchTritonPatch {
      rev = "8643f2a69732482dfeff4f4deb9176bc0f144ee1";
      file = "iputils/iputils-20151218-nonroot-floodping.patch";
      sha256 = "c67c1b5b332b1d9c14bd2c2eaa8c8b8e6a937fa30d14213c4ac9acdd18dc9f9c";
    })
  ];

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
    "USE_GCRYPT=yes"
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
    libgcrypt
    libidn
    nettle
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
    install -vDm 755 ping6 $out/bin/ping6
    install -vDm 755 tracepath $out/bin/tracepath
    install -vDm 755 tracepath6 $out/bin/tracepath6
    install -vDm 755 clockdiff $out/bin/clockdiff
    install -vDm 755 arping $out/bin/arping
    install -vDm 755 rdisc $out/bin/rdisc
    install -vDm 755 ninfod/ninfod $out/bin/ninfod
    install -vDm 755 tracepath $out/bin/tracepath
    install -vDm 755 tracepath $out/bin/tracepath

    install -vDm 644 doc/clockdiff.8 $out/share/man/man8/clockdiff.8
    install -vDm 644 doc/arping.8 $out/share/man/man8/arping.8
    install -vDm 644 doc/ping.8 $out/share/man/man8/ping.8
    install -vDm 644 doc/rdisc.8 $out/share/man/man8/rdisc.8
    install -vDm 644 doc/tracepath.8 $out/share/man/man8/tracepath.8
    install -vDm 644 doc/ninfod.8 $out/share/man/man8/ninfod.8
    ln -s $out/share/man/man8/{ping,ping6}.8
    ln -s $out/share/man/man8/{tracepath,tracepath6}.8
  '' + ''
    runHook 'postInstall'
  '';

  parallelBuild = false;

  meta = with stdenv.lib; {
    description = "Network monitoring tools including ping and ping6";
    homepage = http://www.skbuff.net/iputils/;
    license = licenses.bsdOriginal;
    maintainers = with maintainers; [ ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
