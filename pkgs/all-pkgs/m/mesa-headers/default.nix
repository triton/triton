{ stdenv
, lib

, mesa
}:

stdenv.mkDerivation rec {
  name = "mesa-headers-${mesa.version}";

  inherit (mesa) meta src;

  configurePhase = ":";

  buildPhase = ":";

  installPhase = ''
     local -a mesa_headers=(
       'EGL/eglextchromium.h'
       'EGL/eglmesaext.h'
       'GLES3/gl3ext.h'
     )
     local mesa_header
     for mesa_header in "''${mesa_headers[@]}"; do
        install -D -m644 -v include/"$mesa_header" \
          "$out"/include/"$mesa_header"
     done
  '';
}
