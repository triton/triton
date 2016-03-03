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
  name = "serf-1.3.8";

  src = fetchurl {
    url = "http://archive.apache.org/dist/serf/${name}.tar.bz2";
    sha256 = "14155g48gamcv5s0828bzij6vr14nqmbndwq8j8f9g6vcph0nl70";
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

  meta = with stdenv.lib; {
    description = "HTTP client library based on APR";
    license = licenses.asl20;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
