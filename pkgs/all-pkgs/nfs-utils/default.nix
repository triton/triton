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
  version = "1.3.3";
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
    multihash = "Qmc8KJfF9mssK2CCZ5cgpvaS3Tw22BbHjz6WHWFq8mweah";
    sha256 = "fe8e04f7a869975e11765085d27e91ca3f765e08811a527bb4e32056e41176eb";
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
