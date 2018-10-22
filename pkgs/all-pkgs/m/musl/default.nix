{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "musl-1.1.20";

  src = fetchurl {
    url = "https://www.musl-libc.org/releases/${name}.tar.gz";
    multihash = "QmeeVzpstMMaRrY8AL9MYmDh3kZjFv2Pw4Q12vhWeQ1AEV";
    hashOutput = false;
    sha256 = "44be8771d0e6c6b5f82dd15662eb2957c9a3173a19a8b49966ac0542bbd40d61";
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
  disableStatic = false;

  # Dont depend on a shell potentially from the bootstrap
  dontPatchShebangs = true;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "8364 8929 0BB6 B70F 99FF  DA05 56BC DB59 3020 450F";
      };
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
