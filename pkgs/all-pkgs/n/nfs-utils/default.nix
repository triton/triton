{ stdenv
, fetchurl

, keyutils
, krb5_lib
, libcap
, libevent
, libnfsidmap
, libtirpc
, lvm2
, openldap
, sqlite
, util-linux_lib
}:

let
  version = "2.3.3";
  name = "nfs-utils-${version}";

  baseTarballs = [
    "mirror://sourceforge/nfs/nfs-utils/${version}/${name}.tar"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = map (n: "${n}.xz") baseTarballs;
    hashOutput = false;
    sha256 = "3c8c63611c7e78b7a3b2f8a28b9928a5b5e66d5e9ad09a1e54681508884320a4";
  };

  buildInputs = [
    keyutils
    krb5_lib
    libcap
    libevent
    libnfsidmap
    libtirpc
    lvm2
    openldap
    sqlite
    util-linux_lib
  ];

  postPatch = ''
    sed -i 's,/usr/sbin,/run/current-system/sw/bin,g' utils/statd/statd.c
    sed -i "s,/usr/lib/systemd,$out/lib/systemd,g" systemd/Makefile.in

    sed -i 's,chmod 4511,chmod 0511,' utils/mount/Makefile.in
  '';

  preConfigure = ''
    configureFlagsArray+=(
      "--with-systemd=$out/lib/systemd/system"
    )
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    #"--enable-svcgss"
    "--enable-libmount-mount"
    "--with-statduser=rpcuser"
    "--with-start-statd=/run/current-system/bin/start-statd"
    "--without-tcp-wrappers"
    "--with-krb5=${krb5_lib}"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sbindir=$out/bin"
      "statedir=$TMPDIR"
      "statdpath=$TMPDIR"
    )
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sign") baseTarballs;
        pgpDecompress = true;
        pgpKeyFingerprint = "E1B7 1E33 9E20 A10A 676F  7CB6 9AFB 1D68 1A12 5177";
      };
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
