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
  name = "syslinux-2017-11-23";

  src = fetchFromGitHub {
    version = 6;
    owner = "geneC";
    repo = "syslinux";
    rev = "2ea44cbedb297bd6b409d5c1e0402d5f89592be4";
    sha256 = "0ef8c5db49163d2770e15b9a51cc87bc0343e61b046b31bb08ed78094f4a73a2";
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
  buildParallel = false;
  installParallel = false;

  meta = with stdenv.lib; {
    homepage = http://www.syslinux.org/;
    description = "A lightweight bootloader";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
