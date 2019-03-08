{ stdenv
, fetchFromGitHub
, lib
}:

let
  date = "2018-08-16";
in
stdenv.mkDerivation rec {
  name = "eglexternalplatform-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "NVIDIA";
    repo = "eglexternalplatform";
    rev = "7c8f8e2218e46b1a4aa9538520919747f1184d86";
    sha256 = "33d77361ad622351753b4162d130445d1b6e53e51c40eace940ac3058af2299f";
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
