{ stdenv
, fetchurl

, libmnl
, libnfnetlink
}:

stdenv.mkDerivation rec {
  name = "libnetfilter_conntrack-1.0.8";

  src = fetchurl {
    url = "http://netfilter.org/projects/libnetfilter_conntrack/files/${name}.tar.bz2";
    multihash = "QmcGm5JexFwewNs1qEEY5WfzaxRx9nmVc2sntvzb6RFx6A";
    hashOutput = false;
    sha256 = "0cd13be008923528687af6c6b860f35392d49251c04ee0648282d36b1faec1cf";
  };

  buildInputs = [
    libmnl
    libnfnetlink
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      fullOpts = {
        pgpsigUrl = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprint = "C09D B206 3F1D 7034 BA61  52AD AB46 55A1 26D2 92E4";
      };
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Userspace library providing an API to the in-kernel connection tracking state table";
    homepage = http://netfilter.org/projects/libnetfilter_conntrack/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
