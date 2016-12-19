{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "musl-1.1.15";

  src = fetchurl {
    url = "https://www.musl-libc.org/releases/${name}.tar.gz";
    multihash = "QmTjF42AzBFrByH6tJsrCrNyMBpijo8QLed4beVFyq2363";
    sha256 = "97e447c7ee2a7f613186ec54a93054fe15469fe34d7d323080f7ef38f5ecb0fa";
  };

  preConfigure = ''
    configureFlagsArray+=("--syslibdir=$out/lib")
  '';

  configureFlags = [
    "--enable-shared"
    "--enable-static"
  ];

  # We need this for embedded things like busybox
  dontDisableStatic = true;

  # Dont depend on a shell potentially from the bootstrap
  dontPatchShebangs = true;

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
