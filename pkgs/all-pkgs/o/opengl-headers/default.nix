{ stdenv
, fetchFromGitHub
, lib
}:

# TODO: build release tarballs, repo vendors pdfs

let
  version = "2017-09-10";
in
stdenv.mkDerivation rec {
  name = "opengl-headers-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "KhronosGroup";
    repo = "OpenGL-Registry";
    rev = "93e0595941ea275b95ba115e1f400283c652004d";
    sha256 = "40b8204a8c97e95913c31d11dc58527780e866424c5dd577f9a8ee2209612209";
  };

  configurePhase = ":";

  buildPhase = ":";

  installPhase = ''
    for api in api/GL{,ES{,2,3},SC{,2}}; do
      pushd $api
        while read header; do
          echo $header >&2
          install -D -m644 -v $header $out/include/$(basename "$api")/$header
        done < <(find . -name "*.h" -printf '%P\n')
      popd
    done
  '';

  meta = with lib; {
    description = "OpenGL, OpenGL ES, and OpenGL ES-SC API headers.";
    homepage = https://github.com/KhronosGroup/OpenGL-Registry;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
