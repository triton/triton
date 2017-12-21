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
  version = "2.3.1";
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
    sha256 = "245ec2f9abb51bcc233b64f6f3e9ac8e5cd16ffd35dba9450f83ce2803844cda";
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
      pgpsigUrls = map (n: "${n}.sign") baseTarballs;
      pgpDecompress = true;
      pgpKeyFingerprint = "E1B7 1E33 9E20 A10A 676F  7CB6 9AFB 1D68 1A12 5177";
      inherit (src) urls outputHash outputHashAlgo;
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
