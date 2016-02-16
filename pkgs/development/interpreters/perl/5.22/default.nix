{ stdenv, fetchurl, enableThreading ? true }:

let

  libc = if stdenv.cc.libc or null != null then stdenv.cc.libc else "/usr";

in

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "perl-5.22.1";

  src = fetchurl {
    url = "mirror://cpan/src/5.0/${name}.tar.gz";
    sha256 = "09wg24w5syyafyv87l6z8pxwz4bjgcdj996bx5844k6m9445sirb";
  };

  outputs = [ "out" "man" ];

  patches =
    [ # Do not look in /usr etc. for dependencies.
      ./no-sys-dirs.patch
    ];

  # Build a thread-safe Perl with a dynamic libperls.o.  We need the
  # "installstyle" option to ensure that modules are put under
  # $out/lib/perl5 - this is the general default, but because $out
  # contains the string "perl", Configure would select $out/lib.
  # Miniperl needs -lm. perl needs -lrt.
  configureFlags =
    [ "-de"
      "-Dcc=cc"
      "-Uinstallusrbinperl"
      "-Dinstallstyle=lib/perl5"
      "-Duseshrplib"
      "-Dlocincpth=${libc}/include"
      "-Dloclibpth=${libc}/lib"
    ]
    ++ optional enableThreading "-Dusethreads";

  configureScript = "${stdenv.shell} ./Configure";

  dontAddPrefix = true;

  postPatch = ''
    pwd="$(type -P pwd)"
    substituteInPlace dist/PathTools/Cwd.pm \
      --replace "pwd_cmd = 'pwd'" "pwd_cmd = '$pwd'"
  '';

  preConfigure =
    ''
      configureFlags="$configureFlags -Dprefix=$out -Dman1dir=$out/share/man/man1 -Dman3dir=$out/share/man/man3"
    '' + optionalString (!enableThreading) ''
      # We need to do this because the bootstrap doesn't have a static libpthread
      sed -i 's,\(libswanted.*\)pthread,\1,g' Configure
    '';

  preBuild = optionalString (!(stdenv ? cc && stdenv.cc.nativeTools))
    ''
      # Make Cwd work on NixOS (where we don't have a /bin/pwd).
      substituteInPlace dist/PathTools/Cwd.pm --replace "'/bin/pwd'" "'$(type -tP pwd)'"
    '';

  # Inspired by nuke-references, which I can't depend on because it uses perl. Perhaps it should just use sed :)
  postInstall = ''
    self=$(echo $out | sed -n "s|^$NIX_STORE/\\([a-z0-9]\{32\}\\)-.*|\1|p")

    sed -i "/$self/b; s|$NIX_STORE/[a-z0-9]\{32\}-|$NIX_STORE/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-|g" "$out"/lib/perl5/*/*/Config.pm
    sed -i "/$self/b; s|$NIX_STORE/[a-z0-9]\{32\}-|$NIX_STORE/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee-|g" "$out"/lib/perl5/*/*/Config_heavy.pl
  '';

  setupHook = ./setup-hook.sh;

  passthru.libPrefix = "lib/perl5/site_perl";

  preCheck = ''
    # Try and setup a local hosts file
    if [ -f "${libc}/lib/libnss_files.so" ]; then
      mkdir $TMPDIR/fakelib
      cp "${libc}/lib/libnss_files.so" $TMPDIR/fakelib
      sed -i 's,/etc/hosts,/dev/fd/3,g' $TMPDIR/fakelib/libnss_files.so
      export LD_LIBRARY_PATH=$TMPDIR/fakelib
    fi
  '';

  postCheck = ''
    unset LD_LIBRARY_PATH
  '';

  meta = {
    homepage = https://www.perl.org/;
    description = "The standard implementation of the Perl 5 programmming language";
    maintainers = [ maintainers.eelco ];
    platforms = platforms.all;
  };
}
