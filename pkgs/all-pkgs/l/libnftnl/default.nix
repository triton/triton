{ stdenv
, fetchurl

, jansson
, libmnl
, mxml
}:

stdenv.mkDerivation rec {
  name = "libnftnl-1.0.7";

  src = fetchurl {
    url = "http://netfilter.org/projects/libnftnl/files/${name}.tar.bz2";
    hashOutput = false;
    multihash = "QmaLSceBQqCPeMYLacsroxuMFhqfqFVhksq7Aj66ACfEW5";
    sha256 = "9bb66ecbc64b8508249402f0093829f44177770ad99f6042b86b3a467d963982";
  };

  buildInputs = [
    jansson
    libmnl
    mxml
  ];

  configureFlags = [
    "--with-json-parsing"
    "--with-xml-parsing"
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
