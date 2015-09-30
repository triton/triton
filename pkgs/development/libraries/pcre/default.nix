{ stdenv, fetchurl, unicodeSupport ? true, cplusplusSupport ? true
, windows ? null
}:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "pcre-8.38-RC1";

  src = fetchurl {
    url = "http://pub.wak.io/nixos/tarballs/${name}.tar.bz2";
    sha256 = "60106bd136df843b9542127ffe6767e66a8d8452de345b1ed5c9e1b7f2376379";
  };

  outputs = [ "out" "doc" "man" ];

  configureFlags = ''
    --enable-jit
    ${if unicodeSupport then "--enable-unicode-properties" else ""}
    ${if !cplusplusSupport then "--disable-cpp" else ""}
  '';

  doCheck = with stdenv; !(isCygwin || isFreeBSD);
    # XXX: test failure on Cygwin
    # we are running out of stack on both freeBSDs on Hydra

  crossAttrs = optionalAttrs (stdenv.cross.libc == "msvcrt") {
    buildInputs = [ windows.mingw_w64_pthreads.crossDrv ];
  };

  meta = {
    homepage = "http://www.pcre.org/";
    description = "A library for Perl Compatible Regular Expressions";
    license = stdenv.lib.licenses.bsd3;

    longDescription = ''
      The PCRE library is a set of functions that implement regular
      expression pattern matching using the same syntax and semantics as
      Perl 5. PCRE has its own native API, as well as a set of wrapper
      functions that correspond to the POSIX regular expression API. The
      PCRE library is free, even for building proprietary software.
    '';

    platforms = platforms.all;
    maintainers = [ maintainers.simons ];
  };
}
