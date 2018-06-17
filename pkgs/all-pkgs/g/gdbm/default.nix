{ stdenv
, fetchurl

, ncurses
, readline
}:

let
  version = "1.15";

  tarballUrls = version: [
    "mirror://gnu/gdbm/gdbm-${version}.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "gdbm-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "f9fde3207f67ed8a5a5ddd8ad5e7acf7b27c2cf0f20dfbdde876dcd6e3d2dc0e";
  };

  buildInputs = [
    ncurses
    readline
  ];

  doCheck = true;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.15";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "325F 650C 4C2B 6AD5 8807  327A 3602 B07F 55D0 C732";
      inherit (src) outputHashAlgo;
      outputHash = "f9fde3207f67ed8a5a5ddd8ad5e7acf7b27c2cf0f20dfbdde876dcd6e3d2dc0e";
    };
  };

  meta = with stdenv.lib; {
    description = "GNU dbm key/value database library";
    homepage = http://www.gnu.org/software/gdbm/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
