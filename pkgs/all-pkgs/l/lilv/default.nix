{ stdenv
, fetchurl
, lib
, waf

, lv2
, serd
, sord
, sratom
}:

stdenv.mkDerivation rec {
  name = "lilv-0.24.0";

  src = fetchurl {
    url = "https://download.drobilla.net/${name}.tar.bz2";
    sha256 = "fa60de536d3648aa3b1a445261fd77bd80d0246a071eed2e7ca51ea91a27fb9e";
  };

  nativeBuildInputs = [
    waf
  ];

  buildInputs = [
    lv2
    serd
    sord
    sratom
  ];

  postPatch = /* Fix compatibility with newer autowaf */ ''
    sed -i wscript \
      -e 's/test=True/debug_by_default=False/'
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "907D 226E 7E13 FA33 7F01  4A08 3672 782A 9BF3 68F3";
    };
  };

  meta = with lib; {
    description = "A C library to make the use of LV2 plugins";
    homepage = https://drobilla.net/software/lilv;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
