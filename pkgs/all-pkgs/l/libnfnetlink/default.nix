{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libnfnetlink-1.0.1";

  src = fetchurl {
    url = "http://www.netfilter.org/projects/libnfnetlink/files/${name}.tar.bz2";
    allowHashOutput = false;
    multihash = "QmcoF15dCUWD9DjMKdPUtmZaJELf88o6kQSKkUwBfoHa7G";
    sha256 = "06mm2x4b01k3m7wnrxblk9j0mybyr4pfz28ml7944xhjx6fy2w7j";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrl = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "C09D B206 3F1D 7034 BA61  52AD AB46 55A1 26D2 92E4";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Low-level library for netfilter kernel/userspace communication";
    homepage = http://www.netfilter.org/projects/libnfnetlink/index.html;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
