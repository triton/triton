{ stdenv
, fetchurl
, lib

, glib
}:

stdenv.mkDerivation rec {
  name = "libvisual-0.4.0";

  src = fetchurl {
    url = "mirror://sourceforge/libvisual/libvisual/${name}/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "78f38d3ce857edde5482aa4415b504bbcd4d4a688fd4de09ec2131ad08174279";
  };

  buildInputs = [
    glib
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = { };
    };
  };

  meta = with lib; {
    description = "An abstraction library for audio visualisations";
    homepage = "http://sourceforge.net/projects/libvisual/";
    license = licenses.lgpl21Plus;
    platforms = platforms.all;
  };
}
