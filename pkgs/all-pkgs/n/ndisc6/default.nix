{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "ndisc6-1.0.3";
  
  src = fetchurl {
    url = "http://www.remlab.net/files/ndisc6/${name}.tar.bz2";
    hashOutput = false;
    multihash = "QmYXNRRL2YtRRZiuw8VnBR3KAfdsQEs82oRa2xq1s2NTmQ";
    sha256 = "0f41d6caf5f2edc1a12924956ae8b1d372e3b426bd7b11eed7d38bc974eec821";
  };

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "localstatedir=$TMPDIR"
    )
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "9480 5833 53E3 34D2 F03F  E80C C3EC 6DBE DD6D 12BD";
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
