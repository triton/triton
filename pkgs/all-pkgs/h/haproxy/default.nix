{ stdenv
, fetchurl

, lua
, openssl
, pcre2
, systemd_lib
, zlib
}:

let
  major = "1.8";
  version = "${major}.4";
in
stdenv.mkDerivation rec {
  name = "haproxy-${version}";
  
  src = fetchurl {
    url = "https://www.haproxy.org/download/${major}/src/${name}.tar.gz";
    multihash = "QmUDhzY9mXo78Fenmr9vvfz4BsH1vH8nHPC6hoaehg8JV4";
    hashOutput = false;
    sha256 = "e305b0a4e7dec08072841eef6ac6dcd1b5586b1eff09c2d51e152a912e8884a6";
  };

  buildInputs = [
    lua
    openssl
    pcre2
    systemd_lib
    zlib
  ];

  preBuild = ''
    cat Makefile
    makeFlagsArray+=("PREFIX=$out")
  '';

  buildFlags = [
    "TARGET=linux2628"
    "USE_PCRE2=1"
    "USE_PCRE2_JIT=1"
    "USE_THREAD=1"
    "USE_PTHREAD_PSHARED=1"
    "USE_REGPARM=1"
    "USE_GETADDRINFO=1"
    "USE_OPENSSL=1"
    "USE_LUA=1"
    "USE_ZLIB=1"
    "USE_SYSTEMD=1"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      md5Urls = map (n: "${n}.md5") src.urls;
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = "http://libpipeline.nongnu.org";
    description = "C library for manipulating pipelines of subprocesses in a flexible and convenient way";
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
