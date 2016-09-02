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
  name = "cifs-utils-6.5";

  src = fetchurl {
    url = "mirror://samba/linux-cifs/cifs-utils/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "e2776578b8267c6dc0862897f5e10f87f10f8337fca9ca6a9118f5eb30cf49f7";
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
