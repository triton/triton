{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libev-4.24";

  src = fetchurl {
    urls = [
      "mirror://gentoo/distfiles/${name}.tar.gz"
      "http://dist.schmorp.de/libev/Attic/${name}.tar.gz"
    ];
    multihash = "QmPXg8u39fKvwp1TY6bjE54GScPizDGQWE6Lb5pXd4AxT6";
    sha256 = "973593d3479abdf657674a55afe5f78624b0e440614e2b8cb3a07f16d4d7f821";
  };

  # Fix c89 compliance
  # Without this libverto is broken
  postPatch = ''
    grep -q '__STDC_VERSION__ >= 199901L' ev.h
    sed -i 's,__STDC_VERSION__ >= 199901L.*,__STDC_VERSION__ >= 199901L,' ev.h
  '';

  meta = with stdenv.lib; {
    description = "A high-performance event loop/event model with lots of features";
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
