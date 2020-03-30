{ stdenv
, fetchurl
, lib
, unzip
}:

let
  version = "13.0.0";
in
stdenv.mkDerivation rec {
  name = "unicode-character-database-${version}";

  srcs = [
    (fetchurl {
      url = "http://www.unicode.org/Public/${version}/ucd/UCD.zip";
      multihash = "QmcEUFWGdfmcGEM4UdEksvjGD943P5ZBg2WNEaTfMqJcP5";
      sha256 = "2f76973b4d36ae45584f5a45ec65b47138932d777dd23a5669c89535ef3da951";
    })
    (fetchurl {
      url = "http://www.unicode.org/Public/${version}/ucd/Unihan.zip";
      multihash = "QmVz53sq2msSKr5fRHk8LUyU7C7tbax3W1HhNaB1p1C2dn";
      sha256 = "e380194c4835ad85aa50e8750a58c1f605dbfc4aba9e3e3b0ca25b9530c02f64";
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
