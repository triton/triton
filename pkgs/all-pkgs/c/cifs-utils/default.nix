{ stdenv
, fetchurl

, kerberos
, keyutils
, libcap-ng
, pam
, samba_client
, talloc
}:

stdenv.mkDerivation rec {
  name = "cifs-utils-6.7";

  src = fetchurl {
    url = "mirror://samba/linux-cifs/cifs-utils/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "b2f21612474ab012e75accd167aab607a0614ff67efb56ea0f36789fa785cfab";
  };

  buildInputs = [
    kerberos
    keyutils
    libcap-ng
    pam
    samba_client
    talloc
  ];

  preBuild = ''
    makeFlagsArray+=("root_sbindir=$out/sbin")
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "98ED EB95 6384 61E7 8CE8  3B79 5AFD BFB2 70F3 B981";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Tools for managing Linux CIFS client filesystems";
    homepage = http://www.samba.org/linux-cifs/cifs-utils/;
    license = licenses.lgpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
