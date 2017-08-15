{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "musl-1.1.16";

  src = fetchurl {
    url = "https://www.musl-libc.org/releases/${name}.tar.gz";
    multihash = "QmZmqPbtjUsWo61PKm9nrpQnwRxbhUCwDo4KDgT4TMeHDS";
    hashOutput = false;
    sha256 = "937185a5e5d721050306cf106507a006c3f1f86d86cd550024ea7be909071011";
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
