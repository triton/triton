{ stdenv
, fetchurl
}:

let
  tarballUrls = version: [
    "https://ftp.pcre.org/pub/pcre/pcre2-${version}.tar.bz2"
    "http://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre2-${version}.tar.bz2"
    "mirror://sourceforge/pcre/pcre/${version}/pcre2-${version}.tar.bz2"
  ];

  version = "10.33";
in
stdenv.mkDerivation rec {
  name = "libpcre2-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "35514dff0ccdf02b55bd2e9fa586a1b9d01f62332c3356e379eabb75f789d8aa";
  };

  preBuild = ''
    for file in $(find . -name Makefile); do
      sed -i 's,^\(all\|install\)-am:,\1-oldam:,' "$file"
      echo 'all-am: $(LTLIBRARIES) $(HEADERS) $(pkgconfig_DATA)' >>"$file"
      echo 'install-am:' >>"$file"
      if grep -q 'install-pkgconfigDATA' "$file"; then
        echo 'install-am: install-pkgconfigDATA' >>"$file"
      fi
      if grep -q 'install-binSCRIPTS' "$file"; then
        echo 'install-am: install-binSCRIPTS' >>"$file"
      fi
      sed -n 's,^\(install-.*\(LTLIBRARIES\|HEADERS\)\):.*$,\1,p' "$file" | \
        xargs echo 'install-am:' >>"$file"
    done
  '';

  configureFlags = [
    "--enable-pcre2-8"
    "--enable-pcre2-16"
    "--enable-pcre2-32"
    "--enable-jit"
  ];

  passthru = {
    inherit version;
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "10.33";
      inherit (src)
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
          # Philip Hazel
        pgpKeyFingerprint = "45F6 8D54 BBE2 3FB3 039B  46E5 9766 E084 FB0F 43D8";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "Perl Compatible Regular Expressions";
    homepage = "http://www.pcre.org/";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
