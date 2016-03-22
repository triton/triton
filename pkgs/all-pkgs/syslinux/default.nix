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
  name = "syslinux-2016-03-09";

  src = fetchFromGitHub {
    owner = "geneC";
    repo = "syslinux";
    rev = "4abebfbcafe90e65ecebabec530d52eddfd7ce3e";
    sha256 = "1xi7qjmfh84s5zzqsd1xj27874qpmxzknw5slq6n4g1whngk7hyh";
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
  parallelInstall = false;

  meta = with stdenv.lib; {
    homepage = http://www.syslinux.org/;
    description = "A lightweight bootloader";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
