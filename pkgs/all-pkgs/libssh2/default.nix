{ stdenv
, fetchurl

, openssl
, zlib
}:

stdenv.mkDerivation rec {
  name = "libssh2-1.7.0";

  src = fetchurl {
    url = "https://www.libssh2.org/download/${name}.tar.gz";
    sha256 = "116mh112w48vv9k3f15ggp5kxw5sj4b88dzb5j69llsh7ba1ymp4";
  };

  buildInputs = [
    openssl
    zlib
  ];

  configureFlags = [
    "--with-openssl"
    "--without-libgcrypt"
    "--without-wincng"
    "--with-libz"
    "--disable-crypt-none"
    "--disable-mac-none"
    "--enable-gex-new"
    # "--enable-clear-memory"  # Use autodetection
    "--disable-debug"
    "--disable-examples-build"
  ];

  meta = with stdenv.lib; {
    description = "A client-side C library implementing the SSH2 protocol";
    homepage = http://www.libssh2.org;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
