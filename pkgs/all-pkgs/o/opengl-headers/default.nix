{ stdenv
, fetchurl
, fetchFromGitHub
, lib
, python3Packages
}:

# We build our own dist tarballs, upstream repo vendors pdfs.

let
  date = "2019-03-01";
in
stdenv.mkDerivation rec {
  name = "opengl-headers-${date}";

  src = fetchurl {
    name = "opengl-headers-${date}.tar.xz";
    multihash = "QmauGzZP6Sk8sef8HytfW9Xik83R6M9UNkAMQ9cmUuL8Ye";
    sha256 = "1d2904278c9670cb1a7720a599761159c583057d2105dcae1408c6eea51ed228";
  };

  configurePhase = ":";

  buildPhase = ":";

  installPhase = ''
    local opengl_api
    for opengl_api in GL{,ES{,2,3},SC{,2}}; do
      pushd $opengl_api/
        local -a opengl_headers
        mapfile -t opengl_headers < <(find . -name '*.h' -printf '%P\n')
        for opengl_header in "''${opengl_headers[@]}"; do
          install -D -m644 -v "$opengl_header" \
            "$out"/include/"$(basename "$opengl_api")"/"$opengl_header"
        done
      popd
    done

    local opengl_xml
    for opengl_xml in xml/*.xml; do
      install -D -m644 -v "$opengl_xml" \
        "$out"/share/opengl-registry/"$(basename "$opengl_xml")"
    done
  '';

  passthru = {
    generateDistTarball = stdenv.mkDerivation rec {
      name = "opengl-headers-${date}";

      src = fetchFromGitHub {
        version = 6;
        owner = "KhronosGroup";
        repo = "OpenGL-Registry";
        rev = "68dba34a93b67d626b1c8b7294e4562bdaf4c996";
        sha256 = "6046f2eef181fe96379d23938de26e32621a59061d384b946db7e969bf16e99a";
      };

      nativeBuildInputs = [
        python3Packages.lxml
        python3Packages.python
      ];

      postPatch = ''
        patchShebangs xml/genheaders.py

        # Fix impure date in headers
        grep -q "time.strftime('%Y%m%d')" xml/genheaders.py
        sed -i xml/genheaders.py \
          -e "s,time.strftime('%Y%m%d'),'${lib.replaceStrings ["-"] [""] date}',"

        # FIXME: remove once Mesa reflects this change
        grep -a 'void <name>glXQueryGLXPbufferSGIX' xml/glx.xml
        sed -i xml/glx.xml \
          -e 's/void <name>glXQueryGLXPbufferSGIX/int <name>glXQueryGLXPbufferSGIX/'
      '';


      configurePhase = ":";

      preBuild = ''
        cd xml/
      '';

      # If Mesa finally aligns their glx.h with the upstream header from
      # Khronos this should be enabled.
      #postBuild = ''
      #  # Fix missing includes in generated glx.h.
      #  # https://www.khronos.org/registry/OpenGL/ABI/#4
      #  grep -q '#define __glx_glx_h_ 1' ../api/GL/glx.h
      #  sed -i ../api/GL/glx.h \
      #    -e '/^#define __glx_glx_h_ 1/a #include <X11/Xlib.h>\n#include <X11/Xutil.h>'
      #'';

      installPhase = ''
        cd ../
        # Install xml registry files.
        local opengl_xml
        for opengl_xml in xml/*.xml; do
          install -D -m644 -v "$opengl_xml" \
            api/xml/"$(basename "$opengl_xml")"
        done

        tar -Jcvf opengl-headers-${date}.tar.xz api/

        install -D -m644 -v 'opengl-headers-${date}.tar.xz' \
          "$out/opengl-headers-${date}.tar.xz"
      '';
    };
  };

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
