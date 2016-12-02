{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "newlib-2.5.0";

  src = fetchurl {
    url = "ftp://sourceware.org/pub/newlib/${name}.tar.gz";
    multihash = "QmfR2FNSz6QB2rugxfR2xnBgcmuxfgQZKG6XdRmXeZ7Snt";
    sha256 = "5b76a9b97c9464209772ed25ce55181a7bb144a66e5669aaec945aa64da3189b";
  };

  buildCommand = ''
    cat $NIX_CC/nix-support/orig-libc
    echo "#######"
    cat $NIX_CC/nix-support/libc-cflags
    echo "#######"
    cat $NIX_CC/nix-support/libc-ldflags-before
    cat $NIX_CC/nix-support/libc-ldflags

    echo "This package is not meant to be built directly"
    exit 1
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
  };
}
