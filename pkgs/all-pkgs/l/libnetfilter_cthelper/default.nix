{ stdenv
, fetchurl

, libmnl
}:

stdenv.mkDerivation rec {
  name = "libnetfilter_cthelper-1.0.0";

  src = fetchurl {
    url = "http://netfilter.org/projects/libnetfilter_cthelper/files/${name}.tar.bz2";
    allowHashOutput = false;
    multihash = "QmYpGYZ68ctStfnDEMggfXS4JUXQ6RkVxbiTN1d9Q8CGwG";
    sha256 = "07618e71c4d9a6b6b3dc1986540486ee310a9838ba754926c7d14a17d8fccf3d";
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
    description = "Userspace library that provides the programming interface to the user-space connection tracking helper infrastructure";
    homepage = http://www.netfilter.org/projects/libnetfilter_cthelper/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
