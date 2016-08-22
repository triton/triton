{ stdenv
, fetchurl

, libmnl
, libnetfilter_acct
}:

stdenv.mkDerivation rec {
  name = "nfacct-1.0.2";

  src = fetchurl {
    url = "http://netfilter.org/projects/nfacct/files/${name}.tar.bz2";
    allowHashOutput = false;
    multihash = "QmZtqnk4vHgPWK5XinUGnvpTMZtCy9AEZM2MzNLecut5EB";
    sha256 = "ecff2218754be318bce3c3a5d1775bab93bf4168b2c4aac465785de5655fbd69";
  };

  buildInputs = [
    libmnl
    libnetfilter_acct
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
    homepage = http://netfilter.org/projects/nfacct/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
