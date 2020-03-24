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

  version = "5.30.2";
in
stdenv.mkDerivation rec {
  name = "perl-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "a1aa88bd6fbbdc2e82938afbb76c408b0ea847317737b712dc196cc7907a5259";
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
    "-Duse64bitall"
    "-Dusethreads"
  ];

  configureScript = "./configure.gnu";

  setupHook = ./setup-hook.sh;

  passthru = {
    libPrefix = "lib/perl5/site_perl";
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "5.30.2";
      outputHash = "a1aa88bd6fbbdc2e82938afbb76c408b0ea847317737b712dc196cc7907a5259";
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
      i686-linux
      ++ x86_64-linux;
  };
}
