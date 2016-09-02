{ stdenv
, fetchurl

, libmnl
, libnfnetlink
}:

stdenv.mkDerivation rec {
  name = "libnetfilter_conntrack-1.0.6";

  src = fetchurl {
    url = "http://netfilter.org/projects/libnetfilter_conntrack/files/${name}.tar.bz2";
    hashOutput = false;
    multihash = "QmdyNB8BoHa5cg2rTyCASLK3mwoGPwRZriJRwtb6XPpt9N";
    sha256 = "efcc08021284e75f4d96d3581c5155a11f08fd63316b1938cbcb269c87f37feb";
  };

  buildInputs = [
    libmnl
    libnfnetlink
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrl = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "C09D B206 3F1D 7034 BA61  52AD AB46 55A1 26D2 92E4";
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
