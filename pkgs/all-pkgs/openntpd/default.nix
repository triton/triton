{ stdenv
, bison
, fetchurl

, libressl
}:

let
  baseUrl = "mirror://openbsd/OpenNTPD";
in
stdenv.mkDerivation rec {
  name = "openntpd-${version}";
  version = "5.9p1";

  src = fetchurl {
    url = "${baseUrl}/${name}.tar.gz";
    allowHashOutput = false;  # Upstream provides it directly
    sha256 = "200c04056d4d6441653cac71d515611f3903aa7b15b8f5661a40dab3fb3697b3";
  };

  nativeBuildInputs = [
    bison
  ];

  buildInputs = [
    libressl
  ];

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
    srcVerified = fetchurl rec {
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
