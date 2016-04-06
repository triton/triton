{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "ipfs-hasher-0.0.0";
  
  src = fetchurl {
    name = "${name}.tar.xz";
    multihash = "QmXCsrxUoJpZENQ17T798n9X7YiCAjc5T3bLDHgLKShQaU";
    sha256 = "5488b02404c3879b974a14bfd2b028c6238489260107bc324883dae9e90c0b28";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
