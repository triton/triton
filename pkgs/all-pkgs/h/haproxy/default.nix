{ stdenv
, fetchurl

, lua
, openssl
, pcre2_lib
, systemd_lib
, zlib
}:

let
  major = "2.0";
  version = "${major}.3";
in
stdenv.mkDerivation rec {
  name = "haproxy-${version}";
  
  src = fetchurl {
    url = "https://www.haproxy.org/download/${major}/src/${name}.tar.gz";
    multihash = "QmVc83Z8UEUYHtNvQB7UzYDX9ZcA7j5heLJzaDqPESJ2ur";
    hashOutput = false;
    sha256 = "aac1ff3e5079997985b6560f46bf265447d0cd841f11c4d77f15942c9fe4b770";
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
    "TARGET=linux-glibc"
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
