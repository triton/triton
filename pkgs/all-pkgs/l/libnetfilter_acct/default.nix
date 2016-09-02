{ stdenv
, fetchurl

, libmnl
}:

stdenv.mkDerivation rec {
  name = "libnetfilter_acct-1.0.3";

  src = fetchurl {
    url = "http://netfilter.org/projects/libnetfilter_acct/files/${name}.tar.bz2";
    hashOutput = false;
    multihash = "QmVjKaUentJQiKjEcPbNy5c5rtfyiMi1SZRseiiCRiXrGj";
    sha256 = "4250ceef3efe2034f4ac05906c3ee427db31b9b0a2df41b2744f4bf79a959a1a";
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
    homepage = http://netfilter.org/projects/libnetfilter_acct/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
