{ stdenv
, bison
, fetchurl
, flex

, libmnl
, libnetfilter_conntrack
, libnetfilter_cthelper
, libnetfilter_cttimeout
, libnetfilter_queue
, libnfnetlink
, libtirpc
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "conntrack-tools-1.4.5";

  src = fetchurl {
    url = "http://www.netfilter.org/projects/conntrack-tools/files/${name}.tar.bz2";
    multihash = "QmctmXVM84zF4VTqkaCGd7hdzr6zi8AqqFgVHET9EUDFFe";
    hashOutput = false;
    sha256 = "36c6d99c7684851d4d72e75bd07ff3f0ff1baaf4b6f069eb7244990cd1a9a462";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  buildInputs = [
    libmnl
    libnetfilter_conntrack
    libnetfilter_cthelper
    libnetfilter_cttimeout
    libnetfilter_queue
    libnfnetlink
    libtirpc
    systemd_lib
  ];

  NIX_CFLAGS_COMPILE = "-I${libtirpc}/include/tirpc";

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-systemd"
  ];

  # We need this for the promotion of caches
  postInstall = ''
    mkdir -p "$out/libexec"
    cp doc/sync/primary-backup.sh "$out/libexec"
    sed \
      -e "s,/usr/sbin,$out/bin,g" \
      -e "s,/var/lock,/run,g" \
      -i "$out/libexec/primary-backup.sh"
    chmod +x "$out/libexec/primary-backup.sh"
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrl = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "C09D B206 3F1D 7034 BA61  52AD AB46 55A1 26D2 92E4";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Connection tracking userspace tools";
    homepage = http://conntrack-tools.netfilter.org/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
