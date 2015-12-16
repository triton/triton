{stdenv, fetchurl, zlib, libpng, freetype, libjpeg, fontconfig}:

stdenv.mkDerivation rec {
  name = "gd-2.1.1";
  
  src = fetchurl {
    url = "https://github.com/libgd/libgd/releases/download/${name}/lib${name}.tar.xz";
    sha256 = "11djy9flzxczphigqgp7fbbblbq35gqwwhn9xfcckawlapa1xnls";
  };
  
  buildInputs = [ zlib libpng freetype ];
  propagatedBuildInputs = [ libjpeg fontconfig ];

  configureFlags = [ "--without-x" ];

  meta = {
    homepage = http://www.libgd.org/;
    description = "An open source code library for the dynamic creation of images by programmers";
  };
}
