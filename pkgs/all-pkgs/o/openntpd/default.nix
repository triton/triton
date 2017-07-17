{ stdenv
, bison
, fetchurl

, libressl
}:

let
  baseUrl = "mirror://openbsd/OpenNTPD";

  version = "6.2p1";
in
stdenv.mkDerivation rec {
  name = "openntpd-${version}";

  src = fetchurl {
    url = "${baseUrl}/${name}.tar.gz";
    hashOutput = false;  # Upstream provides it directly
    sha256 = "05e1668f89969a6ae064f411cb1d864ca3acb27ebd8fac963e6443ea0788d0bc";
  };

  nativeBuildInputs = [
    bison
  ];

  buildInputs = [
    libressl
  ];

  # Remove this rediculous timeout
  postPatch = ''
    grep -q 'timeout = 300;' src/ntp.c
    sed -i '/timeout = 300;/d' src/ntp.c
  '';

  configureFlags = [
    "--with-privsep-path=/var/empty"
    "--with-privsep-user=ntp"
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-cacert=/etc/ssl/certs/ca-certificates.crt"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "localstatedir=$TMPDIR"
    )
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      pgpsigUrl = map (n: "${n}.asc") src.urls;
      sha256Url = "${baseUrl}/SHA256";
      pgpsigSha256Url = "${sha256Url}.asc";
      pgpKeyFile = ./signing.key;
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = "http://www.openntpd.org/";
    description = "OpenBSD NTP daemon (Debian port)";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
