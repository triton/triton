{ stdenv
, fetchurl

, jansson
, libmnl
, mxml
}:

stdenv.mkDerivation rec {
  name = "libnftnl-1.1.6";

  src = fetchurl {
    url = "http://netfilter.org/projects/libnftnl/files/${name}.tar.bz2";
    multihash = "QmYAGPPaTzG5rPqc8STQdEiJohLJfnzp6aUev6MojKR5cm";
    hashOutput = false;
    sha256 = "c1eb5a696fc1d4b3b412770586017bc01af93da3ddd25233d34a62979dee1eca";
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
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrl = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprint = "C09D B206 3F1D 7034 BA61  52AD AB46 55A1 26D2 92E4";
      };
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
