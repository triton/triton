{ stdenv
, fetchurl
, waf

, gtk2
, libsndfile
}:

stdenv.mkDerivation rec {
  name = "lv2-1.14.0";

  src = fetchurl {
    url = "http://lv2plug.in/spec/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "b8052683894c04efd748c81b95dd065d274d4e856c8b9e58b7c3da3db4e71d32";
  };

  nativeBuildInputs = [
    waf
  ];

  buildInputs = [
    gtk2
    libsndfile
  ];

  postPatch = /* Fix compatibility with newer autowaf */ ''
    sed -i wscript \
      -e 's/False, True/False/' \
      -e 's/Options.platform/"random string"/'
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

  meta = with stdenv.lib; {
    description = "A plugin standard for audio systems";
    homepage = http://lv2plug.in;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
