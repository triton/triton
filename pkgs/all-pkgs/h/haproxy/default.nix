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
  version = "${major}.5";
in
stdenv.mkDerivation rec {
  name = "haproxy-${version}";
  
  src = fetchurl {
    url = "https://www.haproxy.org/download/${major}/src/${name}.tar.gz";
    multihash = "QmTZwvP7LAWZmn1rgzNYCe7g8nwerTah5wqAUB4Qs75YXf";
    hashOutput = false;
    sha256 = "407260ce65d7a16d93a037976712a8742985ce29360b6d5c187a849b6c0fbf8c";
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
