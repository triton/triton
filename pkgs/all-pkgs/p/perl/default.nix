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

  version = "5.28.1";
in
stdenv.mkDerivation rec {
  name = "perl-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "fea7162d4cca940a387f0587b93f6737d884bf74d8a9d7cfd978bc12cd0b202d";
  };

  patches = [
    # Do not look in /usr etc. for dependencies.
    (fetchTritonPatch {
      rev = "9493778a087a474b64c5a8d1c954d11cc3b74d56";
      file = "p/perl/no-sys-dirs.patch";
      sha256 = "1cf5868893c61b3b9e0dbddce8e76ccaa7c530299ce1d5240c06091b8a219b46";
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
      urls = tarballUrls "5.28.1";
      outputHash = "fea7162d4cca940a387f0587b93f6737d884bf74d8a9d7cfd978bc12cd0b202d";
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
