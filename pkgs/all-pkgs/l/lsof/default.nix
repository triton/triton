{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "lsof-${version}";
  version = "4.89";

  src = fetchurl {
    urls = [
      "ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof/lsof_${version}.tar.bz2"
      "ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof/OLD/lsof_${version}.tar.bz2"
    ];
    sha256 = "81ac2fc5fdc944793baf41a14002b6deb5a29096b387744e28f8c30a360a3718";
  };

  postUnpack = ''
    tar -xvf $srcRoot/lsof_''${version}_src.tar
    srcRoot="lsof_''${version}_src"
  '';

  postPatch = ''
    # fix POSIX compliance with `echo`
    sed -i {AFSConfig,Configure,Customize,Inventory,tests/CkTestDB} \
      -e 's:echo -n:printf:'
  '';
  
  configurePhase = "./Configure -n linux;";

  # The configure script generates the makefile
  preBuild = ''
    # Undocumented hack for ipv6?
    sed -i Makefile \
      -e 's/^CFGF=/&  -DHASIPv6=1/;'
  '';
  
  installPhase = ''
    install -D -m755 -v 'lsof' "$out/bin/lsof"
    install -D -m644 -v 'lsof.8' "$out/man/man8/lsof.8"
  '';

  meta = with stdenv.lib; {
    description = "A tool to list open files";
    homepage = https://people.freebsd.org/~abe/;
    license = licenses.free; # lsof license
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
