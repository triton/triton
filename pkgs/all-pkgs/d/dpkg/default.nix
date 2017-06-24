{ stdenv
, fetchurl
, lib
, makeWrapper
, perl

, bzip2
, libselinux
, ncurses
, xz
, zlib
}:

let
  version = "1.18.16";
in
stdenv.mkDerivation {
  name = "dpkg-${version}";

  src = fetchurl {
    url = "mirror://debian/pool/main/d/dpkg/dpkg_${version}.tar.xz";
    sha256 = "4b147ccf8753e02e2bb598263b4a0ec51418d3c30da08776bad32059a7741388";
  };

  nativeBuildInputs = [
    makeWrapper
    perl
  ];

  buildInputs = [
    bzip2
    libselinux
    ncurses
    xz
    zlib
  ];

  preConfigure = ''
    export PERL_LIBDIR=$out/${perl.libPrefix}
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "admindir=$TMPDIR/var"
    )
  '';

  preFixup = ''
    perlProgs=($(grep -r '#!${perl}' "$out/bin" | awk -F: '{print $1}' | sort | uniq))
    for perlProg in "''${perlProgs[@]}"; do
      wrapProgram $perlProg \
        --prefix PATH : "$out/bin" \
        --prefix PERL5LIB : "$out/${perl.libPrefix}"
    done
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
