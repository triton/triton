{ stdenv
, fetchurl
, lib
, waf

, serd
}:

stdenv.mkDerivation rec {
  name = "sord-0.16.0";

  src = fetchurl {
    url = "https://download.drobilla.net/${name}.tar.bz2";
    sha256 = "9d3cb2c9966e93f537f37377171f162023cea6784ca069699be4a7770c8a035a";
  };

  nativeBuildInputs = [
    waf
  ];

  buildInputs = [
    serd
  ];

  postPatch = /* Fix compatibility with newer autowaf */ ''
    sed -i wscript \
      -e 's/test=True/debug_by_default=False/' \
      -e 's/Options.options.build_tests/True/'
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "907D 226E 7E13 FA33 7F01  4A08 3672 782A 9BF3 68F3";
    };
  };

  meta = with lib; {
    description = "A lightweight C library for storing RDF data in memory";
    homepage = https://drobilla.net/software/sord;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
