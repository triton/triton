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
}:

stdenv.mkDerivation rec {
  name = "conntrack-tools-1.4.4";

  src = fetchurl {
    url = "http://www.netfilter.org/projects/conntrack-tools/files/${name}.tar.bz2";
    allowHashOutput = false;
    multihash = "QmRzqG5Q7QtX9ZmLAZMyEA1k3m9Lqcd51Utbx6e8WZCkqp";
    sha256 = "b7caf4fcc4c03575df57d25e5216584d597fd916c891f191dac616ce68bdba6c";
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
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
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
