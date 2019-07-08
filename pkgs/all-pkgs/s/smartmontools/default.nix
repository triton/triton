{ stdenv
, fetchurl

, libcap-ng
, systemd-dummy
, systemd_lib
}:

let
  version = "7.0";
in
stdenv.mkDerivation rec {
  name = "smartmontools-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/smartmontools/smartmontools/${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "e5e1ac2786bc87fdbd6f92d0ee751b799fbb3e1a09c0a6a379f9eb64b3e8f61c";
  };

  buildInputs = [
    libcap-ng
    systemd-dummy
    systemd_lib
  ];

  configureFlags = [
    "--with-systemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
    "--with-scriptpath=/no-such-path"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "887B 8C63 2110 4CA8 4A8E  F91B 18EC DA46 CBF6 BAC6";
      };
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
