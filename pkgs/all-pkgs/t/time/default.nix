{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "time-1.9";

  src = fetchurl {
    url = "mirror://gnu/time/${name}.tar.gz";
    hashOutput = false;
    sha256 = "fbacf0c81e62429df3e33bda4cee38756604f18e01d977338e23306a3e3b521e";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "F576 AAAC 1B0F F849 792D  8CB1 29A7 94FD 2272 BC86";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Tool that runs programs and summarizes the system resources they use";
    homepage = http://www.gnu.org/software/time/;
    license = licenses.gpl3;
		maintainers = with maintainers; [
			wkennington
		];
    platforms = with platforms;
      x86_64-linux;
  };
}
