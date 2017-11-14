{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "time-1.8";

  src = fetchurl {
    url = "mirror://gnu/time/${name}.tar.gz";
    hashOutput = false;
    sha256 = "8a2f540155961a35ba9b84aec5e77e3ae36c74cecb4484db455960601b7a2e1b";
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
