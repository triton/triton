{ stdenv
, autoconf
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "autoconf-archive-2016.09.16";

  src = fetchurl {
    url = "mirror://gnu/autoconf-archive/${name}.tar.xz";
    hashOutput = false;
    sha256 = "e8f2efd235f842bad2f6938bf4a72240a5e5fcd248e8444335e63beb60fabd82";
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
