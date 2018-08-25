{ stdenv
, fetchurl

, ncurses
, readline
}:

let
  version = "1.18";

  tarballUrls = version: [
    "mirror://gnu/gdbm/gdbm-${version}.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "gdbm-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "b8822cb4769e2d759c828c06f196614936c88c141c3132b18252fe25c2b635ce";
  };

  buildInputs = [
    ncurses
    readline
  ];

  doCheck = true;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.18";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprint = "325F 650C 4C2B 6AD5 8807  327A 3602 B07F 55D0 C732";
      };
      inherit (src) outputHashAlgo;
      outputHash = "b8822cb4769e2d759c828c06f196614936c88c141c3132b18252fe25c2b635ce";
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
