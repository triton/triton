{ stdenv
, fetchurl

, libmnl
}:

stdenv.mkDerivation rec {
  name = "libnetfilter_cttimeout-1.0.0";

  src = fetchurl {
    url = "http://netfilter.org/projects/libnetfilter_cttimeout/files/${name}.tar.bz2";
    hashOutput = false;
    multihash = "QmfXM2FKbCHPoYdaCie4oTQKYekJfQPkfjngAn9Gv1UCEA";
    sha256 = "aeab12754f557cba3ce2950a2029963d817490df7edb49880008b34d7ff8feba";
  };

  buildInputs = [
    libmnl
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
    description = "Userspace library that provides the programming interface to the connection tracking timeout infrastructure";
    homepage = http://netfilter.org/projects/libnetfilter_cttimeout/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
