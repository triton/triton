{ stdenv
, fetchurl

, keyutils
, krb5_lib
, libcap
, libevent
, libnfsidmap
, libtirpc
, lvm2
, sqlite
, util-linux_lib
}:

let
  version = "1.3.4";
  name = "nfs-utils-${version}";

  baseTarballs = [
    "mirror://sourceforge/nfs/${version}/${name}.tar"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = map (n: "${n}.bz2") baseTarballs;
    allowHashOutput = false;
    multihash = "QmYSe6736HZBZejfyZL3emutsExTrCTtiZ1BEEn4GAnfMS";
    sha256 = "c529c82a82320daae811f3d3a143f83d2714d7e7a43beadd42fcd6022c17d590";
  };

  buildInputs = [
    keyutils
    krb5_lib
    libcap
    libevent
    libnfsidmap
    libtirpc
    lvm2
    sqlite
    util-linux_lib
  ];

  postPatch = ''
    sed -i 's,/usr/sbin,/run/current-system/sw/bin,g' utils/statd/statd.c
  '';

  preConfigure = ''
    configureFlagsArray+=("--with-systemd=$out/lib/systemd/system")
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
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
