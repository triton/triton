{ stdenv
, fetchTritonPatch
, fetchurl

, gtk_2
}:

let
  inherit (stdenv.lib)
    boolEn;
in
stdenv.mkDerivation rec {
  name = "libiodbc-3.52.12";

  src = fetchurl {
    url = "mirror://sourceforge/iodbc/${name}.tar.gz";
    multihash = "QmZFFWKvGPN6yKS3j3FFq29nCtzsM64WNawynAtoWYjnVo";
    sha256 = "51c5ff3a7d9a54202486cb77a3514e0e379a135beefcd5d12b96d1901f9dfb62";
  };

  patches = [
    (fetchTritonPatch {
      rev = "1d5235b2e0dc17b5717eb65bcded3b615327b945";
      file = "l/libiodbc/libiodbc-3.52.7-debian_bug501100.patch";
      sha256 = "d81564fdf0637bacbcbad52d7ad097ec9236f4145ad4f958763747bdc5239158";
    })
    (fetchTritonPatch {
      rev = "1d5235b2e0dc17b5717eb65bcded3b615327b945";
      file = "l/libiodbc/libiodbc-3.52.7-debian_bug508480.patch";
      sha256 = "234990661704b35a475a55f28fe0c7275558bf85c5faf1abac4f94ccb8302113";
    })
    (fetchTritonPatch {
      rev = "1d5235b2e0dc17b5717eb65bcded3b615327b945";
      file = "l/libiodbc/libiodbc-3.52.7-unicode_includes.patch";
      sha256 = "cfa6fc4bdbd200f5eb7d502b9d5878d46a9c7b140b41c876dfda4e42bbda6f97";
    })
  ];

  buildInputs = [
    gtk_2
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--${boolEn (gtk_2 != null)}-gui"
    "--disable-gtktest"
    "--enable-odbc3"
    "--enable-libodbc"
    "--enable-pthreads"
  ];

  meta = with stdenv.lib; {
    description = "ODBC Interface for Linux";
    homepage = http://www.iodbc.org/;
    license = with licenses; [
      bsd2
      lgpl2
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
