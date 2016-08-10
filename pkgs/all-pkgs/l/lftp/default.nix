{ stdenv
, autoconf
, automake
, fetchTritonPatch
, fetchurl
, gettext

, expat
, less
, libidn
, ncurses
, openssl
, readline
, zlib
}:

let
  inherit (stdenv.lib)
    wtFlag;
in

stdenv.mkDerivation rec {
  name = "lftp-4.7.3";

  src = fetchurl {
    urls = [
      "https://lftp.yar.ru/ftp/${name}.tar.bz2"
      "https://lftp.yar.ru/ftp/old/${name}.tar.bz2"
    ];
    sha256 = "4c75f797717c8de614794795926a7b61bb67d2fea598d3bd3f463d837a62551a";
  };

  nativeBuildInputs = [
    autoconf
    automake
    gettext
  ];

  buildInputs = [
    expat
    libidn
    ncurses
    openssl
    readline
    zlib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "0975b3eff32776a9938a6d4a793a1018e559cbf8";
      file = "lftp/lftp-4.5.5-am_config_header.patch";
      sha256 = "7ab090449f8c26624ebe853a0285954c414e31242fcd3db1026bd88d6ebbd6a0";
    })
    (fetchTritonPatch {
      rev = "0975b3eff32776a9938a6d4a793a1018e559cbf8";
      file = "lftp/lftp-4.0.2.91-lafile.patch";
      sha256 = "b54aac35c297657290a2d9571c38bdc4bf51548f826b4ec958a768c398c0cd0b";
    })
    (fetchTritonPatch {
      rev = "de2b07eb93a4af9d8f62bcbfeca721a153c261d4";
      file = "lftp/lftp-4.7.0-gettext.patch";
      sha256 = "0ec82ef206a66aadf40c6c4e4d8697f6edf56bad4744c9722c63a993a2722f34";
    })
  ];

  configureFlags = [
    "--enable-largefile"
    "--enable-threads=posix"
    "--enable-packager-mode"
    "--enable-rpath"
    "--enable-nls"
    "--enable-ipv6"
    "--without-debug"
    "--without-profiling"
    (wtFlag "gnu-ld" (stdenv.cc.isGNU) null)
    #"--with-pager=${less}"
    # TODO: dante socks proxy support
    "--without-socks"
    "--without-socks5"
    #(wtFlag "socksdante" (dante != null) null)
    "--without-socksdante"
    "--with-modules"
    #"--with-sysroot"
    "--without-gnutls"
    (wtFlag "openssl" (openssl != null) openssl)
    "--without-included-regex"
    "--with-libresolv"
    (wtFlag "readline" (readline != null) readline)
    (wtFlag "zlib" (zlib != null) zlib)
    (wtFlag "expat" (expat != null) expat)
    # TODO
    #"--with-dnssec-local-validation"
    (wtFlag "libidn" (libidn != null) null)
  ];

  meta = with stdenv.lib; {
    description = "A ftp/sftp/http/https/torrent client & file transfer program";
    homepage = https://lftp.yar.ru/;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
