{ stdenv
, fetchurl
, lib
, unzip
}:

let
  version = "12.1.0";
in
stdenv.mkDerivation rec {
  name = "unicode-character-database-${version}";

  srcs = [
    (fetchurl {
      url = "http://www.unicode.org/Public/${version}/ucd/UCD.zip";
      multihash = "QmTtBP7ZFuUsWYdyUNQhinWbEDQxnvyPqA49VarVNst5As";
      sha256 = "25ba51a0d4c6fa41047b7a5e5733068d4a734588f055f61e85f450097834a0a6";
    })
    (fetchurl {
      url = "http://www.unicode.org/Public/${version}/ucd/Unihan.zip";
      multihash = "QmUguLv4vL2V6EvxvksexsnEjyvXqoP74LyTKn95vaPdWy";
      sha256 = "6e4553f3b5fffe0d312df324d020ef1278d9595932ae03f4e8a2d427de83cdcd";
    })
  ];

  nativeBuildInputs = [
    unzip
  ];

  srcRoot = ".";

  configurePhase = ":";

  buildPhase = ":";

  installPhase = ''
    local UCD
    for UCD in $srcRoot/*.txt ; do
      install -D -m644 -v "$UCD" \
        "$out/share/unicode-character-database/$(basename "$UCD")"
    done
  '';

  # FIXME
  sourceDateEpochWarn = true;

  meta = with lib; {
    description = "Unicode Character Database";
    homepage = http://www.unicode.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = platforms.all;
  };
}
