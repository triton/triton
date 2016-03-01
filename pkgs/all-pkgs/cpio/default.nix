{ stdenv
, fetchurl
, fetchTritonPatch
}:

stdenv.mkDerivation rec {
  name = "cpio-2.12";

  src = fetchurl {
    url = "mirror://gnu/cpio/${name}.tar.bz2";
    sha256 = "0vi9q475h1rki53100zml75vxsykzyhrn70hidy41s5c2rc8r6bh";
  };

  patches = [
    (fetchTritonPatch {
      rev = "835bca21717df85a24bc5954603f37ca45c261a4";
      file = "cpio/CVE-2015-1197.patch";
      sha256 = "8a4e28af54458edab01c81e6dc39102d78ec270d74be5ae516a77869c64b6516";
    })
    (fetchTritonPatch {
      rev = "835bca21717df85a24bc5954603f37ca45c261a4";
      file = "cpio/CVE-2016-2037.patch";
      sha256 = "03c47239a823c8554c1ad87740d2099161d9697e1affbd89dedd55e2382f5bf6";
    })
  ];

  configureFlags = [
    "--enable-mt"
  ];

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/cpio/;
    description = "A program to create or extract from cpio archives";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
    priority = 1; # resolves collision with gnutar's "libexec/rmt"
  };
}
