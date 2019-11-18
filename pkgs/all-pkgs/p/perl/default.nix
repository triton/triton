{ stdenv
, fetchTritonPatch
, fetchurl
}:

let
  libc = if stdenv.cc.libc or null != null then stdenv.cc.libc else "/usr";

  inherit (stdenv.lib)
    optional
    optionalString;

  tarballUrls = version: [
    "mirror://cpan/src/5.0/perl-${version}.tar.xz"
  ];

  version = "5.30.0";
in
stdenv.mkDerivation rec {
  name = "perl-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "ac501cad4af904d33370a9ea39dbb7a8ad4cb19bc7bc8a9c17d8dc3e81ef6306";
  };

  patches = [
    (fetchTritonPatch {
      rev = "984e5bf6bc386ce45d019e73ebe05ec44cb4389d";
      file = "p/perl/0001-Remove-impure-sysdirs.patch";
      sha256 = "8b4add4d20e290485174c83b03aec9b5e55990d97030c4a444d836922ca2783f";
    })
  ];

  postPatch = ''
    sed -i "/my \$pwd_cmd;/s,;, = '/bin/sh -c pwd';," dist/PathTools/Cwd.pm
  '';

  # Build a thread-safe Perl with a dynamic libperls.o.  We need the
  # "installstyle" option to ensure that modules are put under
  # $out/lib/perl5 - this is the general default, but because $out
  # contains the string "perl", Configure would select $out/lib.
  # Miniperl needs -lm. perl needs -lrt.
  configureFlags = [
    "-de"
    "-Uinstallusrbinperl"
    "-Dinstallstyle=lib/perl5"
    "-Duseshrplib"
    "-Dusethreads"
  ];

  configureScript = "./configure.gnu";

  preFixup = ''
    # We don't want perl to depend on dev paths
    sed -i "s,libpth => '.*',libpth => ' '," "$out"/lib/perl5/*/*/Config.pm
    sed -i "s,\(incpth\|libpth\|libsdirs\|libsfound\|libspath\|timeincl\)='.*',\1=' '," "$out"/lib/perl5/*/*/Config_heavy.pl

    # We don't need to depend on coreutils
    sed -i "s,$(dirname "$(type -tP uname)"),," \
      "$out"/lib/perl5/*/*/Config_heavy.pl \
      "$out"/lib/perl5/*/*/CORE/config.h
  '';

  disallowedReferences = [
    stdenv.cc
  ];

  setupHook = ./setup-hook.sh;

  passthru = {
    libPrefix = "lib/perl5/site_perl";
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "5.30.0";
      outputHash = "ac501cad4af904d33370a9ea39dbb7a8ad4cb19bc7bc8a9c17d8dc3e81ef6306";
      inherit (src) outputHashAlgo;
      fullOpts = {
        sha256Urls = map (n: "${n}.sha256.txt") urls;
        sha1Urls = map (n: "${n}.sha1.txt") urls;
        md5Urls = map (n: "${n}.md5.txt") urls;
      };
    };
  };

  meta = with stdenv.lib; {
    description = "The Perl 5 programmming language";
    homepage = https://www.perl.org/;
    license = with licenses; [
      artistic1
      gpl1Plus
    ];
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux ++
      x86_64-linux ++
      powerpc64le-linux;
  };
}
