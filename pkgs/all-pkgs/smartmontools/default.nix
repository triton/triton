{ stdenv
, fetchurl

, libcap-ng
}:

stdenv.mkDerivation rec {
  name = "smartmontools-6.5";

  src = fetchurl {
    url = "mirror://sourceforge/smartmontools/${name}.tar.gz";
    allowHashOutput = false;
    multihash = "QmW27uSxPozmCPXhwYvmWkVbi6DN37ZDj6ybUkTPZ3qp65";
    sha256 = "89e8bb080130bc6ce148573ba5bb91bfe30236b64b1b5bbca26515d4b5c945bc";
  };

  buildInputs = [
    libcap-ng
  ];

  configureFlags = [
    "--with-libcap-ng"
    "--with-nvme-devicescan"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "F41F 01FC 0784 4958 4FFC  CF57 DF0F 1A49 C4A4 903A";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Tools for monitoring the health of hard drives";
    homepage = http://smartmontools.sourceforge.net/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
