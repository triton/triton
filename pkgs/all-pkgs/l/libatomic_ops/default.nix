{ stdenv
, fetchurl
}:

let
  version = "7.6.4";
in
stdenv.mkDerivation rec {
  name = "libatomic_ops-${version}";

  src = fetchurl {
    url = "https://github.com/ivmai/libatomic_ops/releases/download/v${version}/${name}.tar.gz";
    # We need the multihash because they delete old releases
    multihash = "QmST5RZsZNuJph591t5aYoBmuzxQqpDmCkQsPn1VMBw5Ai";
    sha256 = "5b823d5a685dd70caeef8fc50da7d763ba7f6167fe746abca7762e2835b3dd4e";
  };

  meta = with stdenv.lib; {
    description = ''A library for semi-portable access to hardware-provided atomic memory update operations'';
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
