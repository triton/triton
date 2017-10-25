{ stdenv
, fetchurl
, unzip
}:

let
  version = "9.0.0";
in
stdenv.mkDerivation rec {
  name = "unicode-character-database-${version}";

  srcs = [
    (fetchurl {
      url = "http://www.unicode.org/Public/${version}/ucd/UCD.zip";
      multihash = "QmegKNLtXL7atq9QfUscnQVYNmcbVykJEWKzkuSdxYuVzk";
      sha256 = "df9e028425816fd5117eaea7173704056f88f7cd030681e457c6f3827f9390ec";
    })
    (fetchurl {
      url = "http://www.unicode.org/Public/${version}/ucd/Unihan.zip";
      multihash = "QmezUBbKW2cme2EsXWYm8EWw7tZ76Jm3hygWNtuRZCxojt";
      sha256 = "6afdd48fb3c5d79a527ed27ce2582b2f684c09e16f5d0837fe7e5b0204f46362";
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

  meta = with stdenv.lib; {
    description = "Unicode Character Database";
    homepage = http://www.unicode.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = platforms.all;
  };
}
