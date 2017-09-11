{ stdenv
, fetchFromGitHub
, lib
}:

let
  version = "2017-08-31";
in
stdenv.mkDerivation rec {
  name = "egl-headers-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "KhronosGroup";
    repo = "EGL-Registry";
    rev = "b2701ceb25a4718c1a4c3b7e89a62f0976479756";
    sha256 = "bdaae46c38b52554955ae1197c0b1e838382e4c6ea7c179cd9d91a2ff6fd5e52";
  };

  configurePhase = ":";

  buildPhase = ":";

  installPhase = ''
    for api in api/{EGL,KHR}; do
      pushd $api
        while read header; do
          echo $header >&2
          install -D -m644 -v $header $out/include/$(basename "$api")/$header
        done < <(find . -name "*.h" -printf '%P\n')
      popd
    done
  '';

  meta = with lib; {
    description = "EGL API and Extension headers.";
    homepage = https://github.com/KhronosGroup/EGL-Registry;
    licenses = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
