{ stdenv
, autoconf
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "autoconf-archive-2019.01.06";

  src = fetchurl {
    url = "mirror://gnu/autoconf-archive/${name}.tar.xz";
    hashOutput = false;
    sha256 = "17195c833098da79de5778ee90948f4c5d90ed1a0cf8391b4ab348e2ec511e3f";
  };

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      failEarly = true;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        # Peter Simons
        pgpKeyFingerprint = "1A4F 63A1 3A46 49B6 32F6  5EE1 41BC 28FE 9908 9D72";
      };
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
