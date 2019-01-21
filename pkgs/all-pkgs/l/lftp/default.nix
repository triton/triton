{ stdenv
, autoreconfHook
, fetchTritonPatch
, fetchurl
, gettext
, lib

, expat
, less
, libidn2
, ncurses
, openssl
, readline
, zlib
}:

let
  inherit (lib)
    boolString
    boolWt;
in
stdenv.mkDerivation rec {
  name = "lftp-4.8.4";

  src = fetchurl {
    urls = [
      "https://lftp.yar.ru/ftp/${name}.tar.bz2"
      "https://lftp.yar.ru/ftp/old/${name}.tar.bz2"
    ];
    multihash = "QmVMuN7XwnVHa7CXJszoe8LgFnQ8cVVfdAG7Bhtbg8zvt7";
    sha256 = "a853edbd075b008c315679c7882b6dcc6821ed2365d2ed843a412acd3d40da0e";
  };

  nativeBuildInputs = [
    autoreconfHook
    gettext
  ];

  buildInputs = [
    expat
    libidn2
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
    #"--with-pager=${less}"
    # TODO: dante socks proxy support
    "--without-socks"
    "--without-socks5"
    #"--${boolWt (dante != null)}-socksdante"
    "--without-socksdante"
    "--with-modules"
    #"--with-sysroot"
    "--without-gnutls"
    "--${boolWt (openssl != null)}-openssl${
      boolString (openssl != null) "=${openssl}" ""}"
    "--without-included-regex"
    "--with-libresolv"
    "--${boolWt (readline != null)}-readline${
      boolString (readline != null) "=${readline}" ""}"
    "--${boolWt (zlib != null)}-zlib${
      boolString (zlib != null) "=${zlib}" ""}"
    "--${boolWt (expat != null)}-expat${
      boolString (expat != null) "=${expat}" ""}"
    # TODO
    #"--with-dnssec-local-validation"
    "--${boolWt (libidn2 != null)}-libidn2"
  ];

  meta = with lib; {
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
