{ stdenv
, fetchurl
}:

let
  version = "1.12";

  tarballUrls = version: [
    "mirror://gnu/gdbm/gdbm-${version}.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "gdbm-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "d97b2166ee867fd6ca5c022efee80702d6f30dd66af0e03ed092285c3af9bcea";
  };

  doCheck = true;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.12";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "325F 650C 4C2B 6AD5 8807  327A 3602 B07F 55D0 C732";
      inherit (src) outputHashAlgo;
      outputHash = "d97b2166ee867fd6ca5c022efee80702d6f30dd66af0e03ed092285c3af9bcea";
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
