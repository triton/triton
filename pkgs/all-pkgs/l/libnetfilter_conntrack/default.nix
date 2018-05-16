{ stdenv
, fetchurl

, libmnl
, libnfnetlink
}:

stdenv.mkDerivation rec {
  name = "libnetfilter_conntrack-1.0.7";

  src = fetchurl {
    url = "http://netfilter.org/projects/libnetfilter_conntrack/files/${name}.tar.bz2";
    multihash = "QmYkpHPtdpovy7TU2gvwAfeJp5SWWHe4gHBpxJ7tUMry1m";
    hashOutput = false;
    sha256 = "33685351e29dff93cc21f5344b6e628e41e32b9f9e567f4bec0478eb41f989b6";
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
