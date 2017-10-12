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
  version = "1.18.24";
in
stdenv.mkDerivation {
  name = "dpkg-${version}";

  src = fetchurl {
    url = "mirror://debian/pool/main/d/dpkg/dpkg_${version}.tar.xz";
    sha256 = "d853081d3e06bfd46a227056e591f094e42e78fa8a5793b0093bad30b710d7b4";
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

    grep -q "$TMPDIR" "$out/${perl.libPrefix}"/Dpkg.pm
    sed -i "s,$TMPDIR,,g" "$out/${perl.libPrefix}"/Dpkg.pm
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
