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
  version = "${major}.5";
in
stdenv.mkDerivation rec {
  name = "haproxy-${version}";
  
  src = fetchurl {
    url = "https://www.haproxy.org/download/${major}/src/${name}.tar.gz";
    multihash = "QmNpySfSFy66Z4KSeVCqJLNrvMUfC9wRWQY7rrpvFJzc2k";
    hashOutput = false;
    sha256 = "3f2e0d40af66dd6df1dc2f6055d3de106ba62836d77b4c2e497a82a4bdbc5422";
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
