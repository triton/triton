{ stdenv
, fetchurl
, scons

, apr
, apr-util
, openssl
, kerberos
, zlib
}:

stdenv.mkDerivation rec {
  name = "serf-1.3.9";

  src = fetchurl {
    url = "mirror://apache/serf/${name}.tar.bz2";
    multihash = "QmW49Y4ZNoRj8meZo89mZMrdtvMpQKkgZf9Lv2vxzSK4vW";
    hashOutput = false;
    sha256 = "549c2d21c577a8a9c0450facb5cca809f26591f048e466552240947bdf7a87cc";
  };

  nativeBuildInputs = [
    scons
  ];

  buildInputs = [
    apr
    apr-util
    kerberos
    openssl
    zlib
  ];

  configurePhase = ''
    sed -e '/^env[.]Append(BUILDERS/ienv.Append(ENV={"PATH":os.environ["PATH"]})' -i SConstruct
    sed -e '/^env[.]Append(BUILDERS/ienv.Append(ENV={"NIX_CFLAGS_COMPILE":os.environ["NIX_CFLAGS_COMPILE"]})' -i SConstruct
    sed -e '/^env[.]Append(BUILDERS/ienv.Append(ENV={"NIX_LDFLAGS":os.environ["NIX_LDFLAGS"]})' -i SConstruct
  '';

  buildPhase = ''
    scons -j $NIX_BUILD_CORES \
      PREFIX="$out" \
      OPENSSL="${openssl}" \
      ZLIB="${zlib}" \
      APR="$(echo "${apr}"/bin/*-config)" \
      APU="$(echo "${apr-util}"/bin/*-config)"
      CC="${stdenv.cc}/bin/cc"
      GSSAPI="${kerberos}"
  '';

  installPhase = ''
    scons -j $NIX_BUILD_CORES install
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        sha1Confirm = "26015c63e3bbb108c1689bf2090e4c26351db674";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "HTTP client library based on APR";
    license = licenses.asl20;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
