{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "i2c-tools-3.1.0";

  src = fetchurl {
    name = "${name}.tar.bz2";
    multihash = "QmTkoGdSwJ8gzQ9Wo35aiW9d8opK3RZiXUcFTUmU3uHAw9";
    sha256 = "960023f61de292c6dd757fcedec4bffa7dd036e8594e24b26a706094ca4c142a";
  };

  preBuild = ''
    makeFlagsArray+=("prefix=$out")
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
