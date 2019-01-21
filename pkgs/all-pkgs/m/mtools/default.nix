{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "mtools-4.0.23";

  src = fetchurl {
    url = "mirror://gnu/mtools/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "f188db26751aeb5692a79b2380b440ecc05fd1848a52f869d7ca1193f2ef8ee3";
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
