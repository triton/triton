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
  name = "syslinux-2017-05-31";

  src = fetchFromGitHub {
    version = 3;
    owner = "geneC";
    repo = "syslinux";
    rev = "828a75d005daf87707e883f04909282efb3e764a";
    sha256 = "c631d80c0e89166b8ea3c20c0b9bfacf787e6b22d3986bef214a11aed2727d92";
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
