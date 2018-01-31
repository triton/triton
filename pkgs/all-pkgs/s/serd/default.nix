{ stdenv
, fetchurl
, waf

, pcre
}:

stdenv.mkDerivation rec {
  name = "serd-0.28.0";

  src = fetchurl {
    url = "https://download.drobilla.net/${name}.tar.bz2";
    sha256 = "1df21a8874d256a9f3d51a18b8c6e2539e8092b62cc2674b110307e93f898aec";
  };

  nativeBuildInputs = [
    waf
  ];

  buildInputs = [
    pcre
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
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "907D 226E 7E13 FA33 7F01  4A08 3672 782A 9BF3 68F3";
    };
  };

  meta = with stdenv.lib; {
    homepage = http://drobilla.net/software/serd;
    description = "A library for reading and writing RDF syntax Turtle and NTriples";
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
