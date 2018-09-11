{ stdenv
, fetchurl
, lib

, elfutils
, glib
, popt
, util-linux_lib
}:

stdenv.mkDerivation rec {
  name = "babeltrace-1.5.6";

  src = fetchurl {
    url = "https://www.efficios.com/files/babeltrace/${name}.tar.bz2";
    multihash = "QmbqSyYWVbzJe3r9EPitdytZK6E5mYovrfaQp8xY7ntRmC";
    hashOutput = false;
    sha256 = "5308bc217828dd571b3259f482a85533554064d4563906ff3c5774ecf915bbb7";
  };

  buildInputs = [
    elfutils
    glib
    popt
    util-linux_lib
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-glibtest"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        sha1Urls = map (n: "${n}.sha1") src.urls;
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "7F49 314A 26E0 DE78 4276  80E0 5F1B 2A07 89F1 2B11";
      };
    };
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
