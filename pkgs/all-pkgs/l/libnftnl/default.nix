{ stdenv
, fetchurl

, jansson
, libmnl
, mxml
}:

stdenv.mkDerivation rec {
  name = "libnftnl-1.1.1";

  src = fetchurl {
    url = "http://netfilter.org/projects/libnftnl/files/${name}.tar.bz2";
    multihash = "QmQXBWZTmuxZsntQ9vGoJF39yaY6mPLZemjWL3wWnLonPy";
    hashOutput = false;
    sha256 = "5d6a65413f27ec635eedf6aba033f7cf671d462a2afeacc562ba96b19893aff2";
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
