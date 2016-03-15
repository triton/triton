{ stdenv
, fetchurl

, iproute
, lzo
, openssl
, pam
, systemd_lib
}:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "openvpn-2.3.10";

  src = fetchurl {
    url = "http://swupdate.openvpn.net/community/releases/${name}.tar.gz";
    sha256 = "1xn8kv4v4h4v8mhd9k4s9rilb7k30jgb9rm7n4fwmfrm5swvbc7q";
  };

  buildInputs = [
    iproute
    lzo
    openssl
    pam
    systemd_lib
  ];
  
  configureFlags = [
    "--enable-x509-alt-username"
    "--enable-iproute2"
    "--enable-systemd"
  ];

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
