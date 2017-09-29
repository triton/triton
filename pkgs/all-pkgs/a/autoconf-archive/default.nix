{ stdenv
, autoconf
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "autoconf-archive-2017.09.28";

  src = fetchurl {
    url = "mirror://gnu/autoconf-archive/${name}.tar.xz";
    hashOutput = false;
    sha256 = "5c9fb5845b38b28982a3ef12836f76b35f46799ef4a2e46b48e2bd3c6182fa01";
  };

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      # Peter Simons
      pgpKeyFingerprint = "1A4F 63A1 3A46 49B6 32F6  5EE1 41BC 28FE 9908 9D72";
    };
  };

  meta = with stdenv.lib; {
    description = "Archive of autoconf m4 macros";
    homepage = http://www.gnu.org/software/autoconf-archive/;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = autoconf.meta.platforms;
  };
}
