{ stdenv
, fetchurl
, scons

, ncurses
}:

stdenv.mkDerivation rec {
  name = "gpsd-3.17";

  src = fetchurl {
    url = "mirror://savannah/gpsd/${name}.tar.gz";
    hashOutput = false;
    sha256 = "68e0dbecfb5831997f8b3d6ba48aed812eb465d8c0089420ab68f9ce4d85e77a";
  };

  nativeBuildInputs = [
    scons
  ];

  buildInputs = [
    ncurses
  ];

  preBuild = ''
    makeFlagsArray+=(
      "prefix=$out"
      "python_libdir=$(toPythonPath $out)"
    )
  '';

  # Unsure why this isn't installing the libraries correctly
  postInstall = ''
    find . \( -name libgps\*.so\* -or -name libgps\*.a \) -exec cp --preserve=links {} $out/lib \;
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "4187 6B2F 5794 63A4 9984  3D1D ECC8 208F 8C6C 738D";
      inherit (src) urls outputHashAlgo outputHash;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
