{ stdenv
, fetchTritonPatch
, fetchurl

, enableThreading ? true
}:

let
  libc = if stdenv.cc.libc or null != null then stdenv.cc.libc else "/usr";

  inherit (stdenv.lib)
    optional
    optionalString;

  tarballUrls = version: [
    "mirror://cpan/src/5.0/perl-${version}.tar.xz"
  ];

  version = "5.26.1";
in
stdenv.mkDerivation rec {
  name = "perl-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "fe8208133e73e47afc3251c08d2c21c5a60160165a8ab8b669c43a420e4ec680";
  };

  setupHook = ./setup-hook.sh;

  patches = [
    # Do not look in /usr etc. for dependencies.
    (fetchTritonPatch {
      rev = "9493778a087a474b64c5a8d1c954d11cc3b74d56";
      file = "p/perl/no-sys-dirs.patch";
      sha256 = "1cf5868893c61b3b9e0dbddce8e76ccaa7c530299ce1d5240c06091b8a219b46";
    })
  ];

  # Build a thread-safe Perl with a dynamic libperls.o.  We need the
  # "installstyle" option to ensure that modules are put under
  # $out/lib/perl5 - this is the general default, but because $out
  # contains the string "perl", Configure would select $out/lib.
  # Miniperl needs -lm. perl needs -lrt.
  configureFlags = [
    "-de"
    "-Dcc=cc"
    "-Uinstallusrbinperl"
    "-Dinstallstyle=lib/perl5"
    "-Duseshrplib"
    "-Dlocincpth=${libc}/include"
    "-Dloclibpth=${libc}/lib"
  ] ++ optional enableThreading "-Dusethreads";

  configureScript = "${stdenv.shell} ./Configure";

  postPatch = ''
    pwd="$(type -P pwd)"
    substituteInPlace dist/PathTools/Cwd.pm \
      --replace "pwd_cmd = 'pwd'" "pwd_cmd = '$pwd'"
  '';

  preConfigure = ''
    configureFlags="$configureFlags -Dprefix=$out -Dman1dir=$out/share/man/man1 -Dman3dir=$out/share/man/man3"
  '' + optionalString (!enableThreading)
  /* We need to do this because the bootstrap doesn't have a
     static libpthread */ ''
    sed -i 's,\(libswanted.*\)pthread,\1,g' Configure
  '';

  preBuild = optionalString (!(stdenv ? cc && stdenv.cc.nativeTools))
    /* Make Cwd work on NixOS (where we don't have a /bin/pwd). */ ''
      substituteInPlace dist/PathTools/Cwd.pm --replace "'/bin/pwd'" "'$(type -tP pwd)'"
    '';

  # Inspired by nuke-references, which I can't depend on because it uses perl. Perhaps it should just use sed :)
  postInstall = ''
    self=$(echo $out | sed -n "s|^$NIX_STORE/\\([a-z0-9]\{32\}\\)-.*|\1|p")

    sed -i "/$self/b; s|$NIX_STORE/[a-z0-9]\{32\}-|$NIX_STORE/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-|g" "$out"/lib/perl5/*/*/Config.pm
    sed -i "/$self/b; s|$NIX_STORE/[a-z0-9]\{32\}-|$NIX_STORE/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-|g" "$out"/lib/perl5/*/*/Config_heavy.pl
  '';

  passthru = {
    libPrefix = "lib/perl5/site_perl";
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "5.26.1";
      outputHash = "fe8208133e73e47afc3251c08d2c21c5a60160165a8ab8b669c43a420e4ec680";
      inherit (src) outputHashAlgo;
      sha256Urls = map (n: "${n}.sha256.txt") urls;
      sha1Urls = map (n: "${n}.sha1.txt") urls;
      md5Urls = map (n: "${n}.md5.txt") urls;
    };
  };

  outputs = [ "out" "man" ];

  preCheck =
  /* Try and setup a local hosts file */ ''
    if [ -f "${libc}/lib/libnss_files.so" ] ; then
      mkdir $TMPDIR/fakelib
      cp "${libc}/lib/libnss_files.so" $TMPDIR/fakelib
      sed -i 's,/etc/hosts,/dev/fd/3,g' $TMPDIR/fakelib/libnss_files.so
      export LD_LIBRARY_PATH=$TMPDIR/fakelib
    fi
  '';

  postCheck = ''
    unset LD_LIBRARY_PATH
  '';

  addPrefix = false;

  # This is broken with make 4.2 and perl 5.22.1
  parallelInstall = false;

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
