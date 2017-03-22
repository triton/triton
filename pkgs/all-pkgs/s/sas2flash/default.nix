{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "sas2flash-20.00.00.00";

  src = fetchurl {
    name = "${name}.src";
    multihash = "QmQQfMWrkaVa8EiVs9xLAn7GwGKkxBX1hTtmF78tFkFHaq";
    sha256 = "3197fea4a60a694cf49a7b2eedc25cade7960bb076d519689e2299e68176824a";
  };

  unpackPhase = ":";

  installPhase = ''
    mkdir -p "$out"/bin
    cp $src "$out"/bin/sas2flash
    chmod +x "$out"/bin/sas2flash
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
