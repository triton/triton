{ stdenv
, fetchurl
, lib
, perl
, which
}:

stdenv.mkDerivation rec {
  name = "valgrind-3.15.0";

  src = fetchurl {
    url = "mirror://sourceware/valgrind/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "417c7a9da8f60dd05698b3a7bc6002e4ef996f14c13f0ff96679a16873e78ab1";
  };

  nativeBuildInputs = [
    perl
    which
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-lto"
    "--enable-tls"
  ];

  # We don't need any of the static libraries
  postInstall = ''
    find "$out"/lib -name '*'.a -delete
    rm -r "$out"/lib/pkgconfig
  '';

  stackProtector = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        md5Confirm = "46e5fbdcbc3502a5976a317a0860a975";
      };
    };
  };
  
  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
