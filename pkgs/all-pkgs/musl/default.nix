{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "musl-1.1.14";

  src = fetchurl {
    url = "http://www.musl-libc.org/releases/${name}.tar.gz";
    sha256 = "1ddral87srzk741cqbfrx9aygnh8fpgfv7mjvbain2d6hh6c1xim";
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
      i686-linux
      ++ x86_64-linux;
  };
}
