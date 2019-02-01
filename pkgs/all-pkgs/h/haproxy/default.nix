{ stdenv
, fetchurl

, lua
, openssl
, pcre2_lib
, systemd_lib
, zlib
}:

let
  major = "1.9";
  version = "${major}.3";
in
stdenv.mkDerivation rec {
  name = "haproxy-${version}";
  
  src = fetchurl {
    url = "https://www.haproxy.org/download/${major}/src/${name}.tar.gz";
    multihash = "QmYEgueTx2f5qL1mWj6WD34QtaA7K73HLb3Q9xNQc7b7yo";
    hashOutput = false;
    sha256 = "d22cc11658b790e2da46cd19e7fbf45c456412059852ccebe208a491db070db4";
  };

  buildInputs = [
    lua
    openssl
    pcre2_lib
    systemd_lib
    zlib
  ];

  preBuild = ''
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
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        md5Urls = map (n: "${n}.md5") src.urls;
      };
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
