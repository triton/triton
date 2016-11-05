{ stdenv
, fetchurl
, lib

, boost
, openssl
}:

let
  version = "1.10.8";
in
stdenv.mkDerivation rec {
  name = "asio-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/asio/asio/${version}%20%28Stable%29/${name}.tar.bz2";
    sha256 = "26deedaebbed062141786db8cfce54e77f06588374d08cccf11c02de1da1ed49";
  };

  buildInputs = [
    boost
    openssl
  ];

  configureFlags = [
    "--disable-maintainer-flags"
    "--disable-seperate-compilation"
    "--enable-boost-coroutine"
    "--with-boost=${boost}"
    "--with-openssl=${openssl}"
  ];

  meta = with lib; {
    description = "Library for network and low-level I/O programming";
    homepage = http://asio.sourceforge.net/;
    license = licenses.boost;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };

}
