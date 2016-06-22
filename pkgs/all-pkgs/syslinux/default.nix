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
  name = "syslinux-2016-04-23";

  src = fetchFromGitHub {
    owner = "geneC";
    repo = "syslinux";
    rev = "1a74985b2a404639b08882c57f3147229605dfd5";
    sha256 = "f54b69d00de5b624712b9e0c9fc1b32961beca57f1a4ac78c02a295e89c2fa84";
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
