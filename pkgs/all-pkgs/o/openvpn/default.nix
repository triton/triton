{ stdenv
, fetchurl
, lib

, iproute
, lzo
, openssl
, pam
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "openvpn-2.4.6";

  src = fetchurl {
    url = "https://swupdate.openvpn.net/community/releases/${name}.tar.gz";
    multihash = "QmXhBzryafo7WN2Hho9eVSNKhaxwFa2VugLSL27dKURgKL";
    hashOutput = false;
    sha256 = "738dbd37fcf8eb9382c53628db22258c41ba9550165519d9200e8bebaef4cbe2";
  };

  buildInputs = [
    iproute
    lzo
    openssl
    pam
    systemd_lib
  ];

  # FIXME: check to see if this has been fixed when updating
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
      # https://openvpn.net/index.php/open-source/documentation/sig.html
      pgpKeyFingerprints = [
        # James Yonan
        "C699 B264 0C6D 404E 6454  A9AD 1D0B 4996 1FBF 51F3"
        # Samuli Seppänen
        "0330 0E11 FED1 6F59 715F  9996 C29D 97ED 198D 22A3"  # Old
        "6D04 F8F1 B017 3111 F499  795E 2958 4D9F 4086 4578"
        # Security Mailing List
        "F554 A368 7412 CFFE BDEF  E0A3 12F5 F7B4 2F2B 01E7"
      ];
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
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
