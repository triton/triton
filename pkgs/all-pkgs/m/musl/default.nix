{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "musl-1.1.17";

  src = fetchurl {
    url = "https://www.musl-libc.org/releases/${name}.tar.gz";
    multihash = "Qme8swo1QsMPLnfJPAECpqsUWKeKARoXCe6AU8w8UkMhCS";
    hashOutput = false;
    sha256 = "c8aa51c747a600704bed169340bf3e03742ceee027ea0051dd4b6cc3c5f51464";
  };

  preConfigure = ''
    configureFlagsArray+=("--syslibdir=$out/lib")
  '';

  configureFlags = [
    "--enable-shared"
    "--enable-static"
  ];

  postInstall = ''
   ln -rsv "$out"/lib/ld*.so* "$out"/bin/ldd
  '';

  # We need this for embedded things like busybox
  dontDisableStatic = true;

  # Dont depend on a shell potentially from the bootstrap
  dontPatchShebangs = true;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "8364 8929 0BB6 B70F 99FF  DA05 56BC DB59 3020 450F";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "An efficient, small, quality libc implementation";
    homepage = "http://www.musl-libc.org";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
