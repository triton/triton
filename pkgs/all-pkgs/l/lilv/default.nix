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
  name = "lilv-0.24.2";

  src = fetchurl {
    url = "https://download.drobilla.net/${name}.tar.bz2";
    multihash = "QmVKVW1YHScct59LWj6XBrfzKWCcFsP152GFbKZRkRwNBJ";
    sha256 = "f7ec65b1c1f1734ded3a6c051bbaf50f996a0b8b77e814a33a34e42bce50a522";
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
