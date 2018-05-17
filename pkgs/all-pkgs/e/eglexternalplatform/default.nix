{ stdenv
, fetchFromGitHub
, lib
}:

let
  date = "2018-03-14";
  rev = "e3b182e3253f92bdbb03a71fdbd958bfb69cf3e3";
in
stdenv.mkDerivation rec {
  name = "eglexternalplatform-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "NVIDIA";
    repo = "eglexternalplatform";
    inherit rev;
    sha256 = "2f09000182bb8f0935cf13c23742bee66fc054df88dc9c77e1ea71757661667d";
  };

  postPatch = ''
    sed -i eglexternalplatform.pc \
      -e "s,/usr,$out,"
  '';

  configurePhase = ":";

  buildPhase = ":";

  installPhase = ''
    for header in interface/*.h; do
      install -D -m644 -v $header "$out/include/EGL/$(basename "$header")"
    done

    install -D -m644 -v eglexternalplatform.pc \
      $out/lib/pkgconfig/eglexternalplatform.pc
  '';

  meta = with lib; {
    description = "The EGL External Platform interface";
    homepage = https://github.com/NVIDIA/eglexternalplatform;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
