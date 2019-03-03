{ stdenv
, fetchurl
}:

let
  version = "1.0.5";
in
stdenv.mkDerivation rec {
  name = "judy-${version}";

  src = fetchurl {
    urls = [
      "mirror://sourceforge/judy/Judy-${version}.tar.gz"
      "mirror://gentoo/distfiles/Judy-${version}.tar.gz"
    ];
    multihash = "QmTNHKmtH8cxHbyQLiDkh8pc2AAiu2RRSKN2X1v4neiVMM";
    sha256 = "1sv3990vsx8hrza1mvq3bhvv9m6ff08y4yz7swn6znszz24l0w6j";
  };

  # gcc 4.8 optimisations break judy.
  # http://sourceforge.net/p/judy/mailman/message/31995144/
  preConfigure = ''
    configureFlagsArray+=("CFLAGS=-fno-strict-aliasing -fno-aggressive-loop-optimizations")
  '';

  # Fails for 1.0.5
  buildParallel = false;

  meta = with stdenv.lib; {
    description = "State-of-the-art C library that implements a sparse dynamic array";
    homepage = http://judy.sourceforge.net/;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
