{ stdenv
, fetchurl
, lib
, perl

, iproute
, ppp
}:

stdenv.mkDerivation rec {
  name = "pptp-1.9.0";

  src = fetchurl {
    url = "mirror://sourceforge/pptpclient/pptp/${name}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "0b1e8cbfc578d3f5ab12ee87c5c2c60419abfe9cc445690a8a19c320b11c9201";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    iproute
    ppp
  ];

  postPatch = ''
    sed -i Makefile \
      -e 's/install -o root/install/'
    sed -i routing.c \
      -e 's,/bin/ip,${iproute}/sbin/ip,'
  '';

  preConfigure = ''
    makeFlagsArray+=(
      BINDIR=$out/bin
      MANDIR=$out/share/man/man8
      PPPDIR=$out/etc/ppp
    )
  '';

  makeFlags = [
    "PPPD=${ppp}/bin/pppd"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = false;  # Make sure all mirrors are allowed
      pgpsigUrls = map (n: "${n}.signature") src.urls;
      pgpKeyFingerprints = [
        # James Cameron
        "A602 F7C9 A42C B3B5 4634  A882 6E64 70BF AE24 66C0"
      ];
    };
  };

  meta = with lib; {
    description = "PPTP client for Linux";
    homepage = http://pptpclient.sourceforge.net/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
