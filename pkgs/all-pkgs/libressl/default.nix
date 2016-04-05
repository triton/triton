{ stdenv
, fetchurl
}:

let
  baseUrl = "mirror://openbsd/LibreSSL";
in
stdenv.mkDerivation rec {
  name = "libressl-2.3.3";

  src = fetchurl {
    url = "${baseUrl}/${name}.tar.gz";
    allowHashOutput = false;  # Upstream provides it directly
    sha256 = "76733166187cc8587e0ebe1e83965ef257262a1a676a36806edd3b6d51b50aa9";
  };

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "localstatedir=$TMPDIR"
    )
  '';

  passthru = {
    sourceTarball = fetchurl rec {
      failEarly = true;
      pgpsigUrl = map (n: "${n}.asc") src.urls;
      sha256Url = "${baseUrl}/SHA256";
      pgpsigSha256Url = "${sha256Url}.asc";
      pgpKeyFile = ./signing.key;
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
