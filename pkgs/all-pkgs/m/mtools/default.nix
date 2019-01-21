{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "mtools-4.0.23";

  src = fetchurl {
    url = "mirror://gnu/mtools/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "6061d31aaf65274cf6de3264907028c90badd8b7f22dd1b385617fa353868aed";
  };

  # Fails to install correctly in parallel
  installParallel = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprint = "E151 F8F5 4AE4 F4E9 019F  037B C806 31B2 6F43 1961";
      };
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/mtools/;
    description = "Utilities to access MS-DOS disks";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
