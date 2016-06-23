{ stdenv
, fetchFromGitHub
, makeWrapper
, nasm
, perl
, python

, mtools
, util-linux_lib
}:

stdenv.mkDerivation rec {
  name = "syslinux-2016-06-12";

  src = fetchFromGitHub {
    owner = "geneC";
    repo = "syslinux";
    rev = "fa1629d888d6ee6325fb2de346e49cdd76156ba0";
    sha256 = "0aebbce023098b8acf5b1dbf5c5b2c528734d685eea3ddbaad02556991924ae7";
  };

  nativeBuildInputs = [
    makeWrapper
    nasm
    perl
    python
  ];

  buildInputs = [
    util-linux_lib
  ];

  preBuild = ''
    grep -q '/bin/pwd' Makefile
    sed -i "s,/bin/pwd,$(type -P pwd),g" Makefile

    # Lots of perl / python scripts
    patchShebangs .

    makeFlagsArray+=(
      "BINDIR=$out/bin"
      "SBINDIR=$out/sbin"
      "LIBDIR=$out/lib"
      "INCDIR=$out/include"
      "DATADIR=$out/share"
      "MANDIR=$out/share/man"
      "PERL=$(type -P perl)"
    )
  '';

  makeFlags = [
    "bios"
  ];

  postInstall = ''
    wrapProgram $out/bin/syslinux \
      --prefix PATH : "${mtools}/bin"
  '';

  # We don't need hardening / optimizations for the bios
  optFlags = false;
  pie = false;
  fpic = false;
  noStrictOverflow = false;
  fortifySource = false;
  stackProtector = false;
  optimize = false;

  # Broken in the makefile
  parallelBuild = false;
  parallelInstall = false;

  meta = with stdenv.lib; {
    homepage = http://www.syslinux.org/;
    description = "A lightweight bootloader";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
