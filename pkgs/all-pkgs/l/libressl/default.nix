{ stdenv
, fetchurl
}:

let
  baseUrl = "mirror://openbsd/LibreSSL";
in

stdenv.mkDerivation rec {
  name = "libressl-2.8.2";

  src = fetchurl {
    url = "${baseUrl}/${name}.tar.gz";
    hashOutput = false;  # Upstream provides it directly
    sha256 = "b8cb31e59f1294557bfc80f2a662969bc064e83006ceef0574e2553a1c254fd5";
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
