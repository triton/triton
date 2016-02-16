{ stdenv, fetchurl, apr, scons, openssl, aprutil, zlib, kerberos, gnused }:

stdenv.mkDerivation rec {
  name = "serf-1.3.8";

  src = fetchurl {
    url = "http://archive.apache.org/dist/serf/${name}.tar.bz2";
    sha256 = "14155g48gamcv5s0828bzij6vr14nqmbndwq8j8f9g6vcph0nl70";
  };

  buildInputs = [ apr scons openssl aprutil zlib ]
    ++ stdenv.lib.optional true kerberos;

  configurePhase = ''
    ${gnused}/bin/sed -e '/^env[.]Append(BUILDERS/ienv.Append(ENV={"PATH":os.environ["PATH"]})' -i SConstruct
    ${gnused}/bin/sed -e '/^env[.]Append(BUILDERS/ienv.Append(ENV={"NIX_CFLAGS_COMPILE":os.environ["NIX_CFLAGS_COMPILE"]})' -i SConstruct
    ${gnused}/bin/sed -e '/^env[.]Append(BUILDERS/ienv.Append(ENV={"NIX_LDFLAGS":os.environ["NIX_LDFLAGS"]})' -i SConstruct
  '';

  buildPhase = ''
    scons PREFIX="$out" OPENSSL="${openssl}" ZLIB="${zlib}" APR="$(echo "${apr}"/bin/*-config)" \
        APU="$(echo "${aprutil}"/bin/*-config)" CC="${
          if stdenv.cc.isClang then "clang" else "${stdenv.cc}/bin/gcc"
        }" GSSAPI="${kerberos}"
  '';

  installPhase = ''
    scons install
  '';

  meta = {
    description = "HTTP client library based on APR";
    license = stdenv.lib.licenses.asl20;
    maintainers = [stdenv.lib.maintainers.raskin];
    hydraPlatforms = stdenv.lib.platforms.linux;
  };
}
