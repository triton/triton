{ stdenv
, fetchurl

, iproute
, lzo
, openssl
, pam
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "openvpn-2.3.12";

  src = fetchurl {
    url = "https://swupdate.openvpn.net/community/releases/${name}.tar.gz";
    allowHashOutput = false;
    sha256 = "f5d39b8c55f75b0aab943059b20571452b494146d997b12d48ce9bd753c01cff";
  };

  buildInputs = [
    iproute
    lzo
    openssl
    pam
    systemd_lib
  ];

  # This fix should be removed in 2.3.12+
  postPatch = ''
    sed -i 's,systemd-daemon,systemd,g' configure
  '';

  configureFlags = [
    "--enable-x509-alt-username"
    "--enable-iproute2"
    "--enable-systemd"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      pgpsigUrl = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "0330 0E11 FED1 6F59 715F  9996 C29D 97ED 198D 22A3";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "A robust and highly flexible tunneling application";
    homepage = http://openvpn.net/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
