{ stdenv
, fetchurl
}:

let
  baseUrl = "mirror://openbsd/LibreSSL";
in

stdenv.mkDerivation rec {
  name = "libressl-2.8.3";

  src = fetchurl {
    url = "${baseUrl}/${name}.tar.gz";
    hashOutput = false;  # Upstream provides it directly
    sha256 = "9b640b13047182761a99ce3e4f000be9687566e0828b4a72709e9e6a3ef98477";
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
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = rec {
        pgpsigUrl = map (n: "${n}.asc") src.urls;
        sha256Url = "${baseUrl}/SHA256";
        pgpsigSha256Url = "${sha256Url}.asc";
        pgpKeyFile = ./signing.key;
      };
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
