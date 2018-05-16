{ stdenv
, fetchurl

, jansson
, libmnl
, mxml
}:

stdenv.mkDerivation rec {
  name = "libnftnl-1.1.0";

  src = fetchurl {
    url = "http://netfilter.org/projects/libnftnl/files/${name}.tar.bz2";
    multihash = "QmTZ4qR59TuXFRDDPM9R6SqV3HAAu1myFnScRbPXqFdzuN";
    hashOutput = false;
    sha256 = "ec0eaca11b165110c2b61e6a7b50a7a0a9b17fa04a0c333f795bec2d19f78f6c";
  };

  buildInputs = [
    jansson
    libmnl
  ];

  configureFlags = [
    "--with-json-parsing"
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
    description = "a userspace library providing a low-level netlink API to the in-kernel nf_tables subsystem";
    homepage = http://netfilter.org/projects/libnftnl;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
