{ stdenv
, fetchurl
, gcc
}:

stdenv.mkDerivation rec {
  name = "libstdcxx-${gcc.version}";

  src = gcc.src;

  patches = gcc.patches;

  configureFlags = [
    "--disable-multilib"
  ];

  preConfigure = ''
    mkdir -v build
    cd build
    configureScript='../libstdc++-v3/configure'
  '';

  postInstall = ''
    rm -r "$out"/share
  '';

  # We want static libstdc++
  disableStatic = false;

  # Ensure we don't depend on anything unexpected
  allowedReferences = [
    "out"
    stdenv.cc.libc
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
