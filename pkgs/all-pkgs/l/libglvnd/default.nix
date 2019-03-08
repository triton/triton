{ stdenv
, autoreconfHook
, egl-headers
, fetchFromGitHub
, lib
, mesa-headers
, opengl-headers
, python2

, libx11
, libxext
, xorgproto
}:

let
  date = "2019-02-13";
in
stdenv.mkDerivation rec {
  name = "libglvnd-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "NVIDIA";
    repo = "libglvnd";
    rev = "f92208be88dd06a70b6f79a1cb95571e2762a9ec";
    sha256 = "5dbfd00dd84e527df8b1717a112da6f085b9845b11bdbc5cef131fa537db722c";
  };

  nativeBuildInputs = [
    autoreconfHook
    python2
  ];

  buildInputs = [
    libx11
    libxext
    xorgproto
  ];

  postPatch = ''
    patchShebangs src/generate/

    rm -v src/generate/xml/{egl,gl,glx}.xml
    cp -v ${opengl-headers}/share/opengl-registry/gl{,x}.xml src/generate/xml/
    cp -v ${egl-headers}/share/egl-registry/egl.xml src/generate/xml/
  '';

  configureFlags = [
    "--enable-egl"
    "--enable-glx"
    "--enable-gles"
    "--enable-asm"
    "--enable-tls"
  ];

  NIX_CFLAGS_COMPILE = [
    "-Wno-array-bounds"
  ];

  postInstall = ''
    # Generate dummy pkgconfig files
    tolower() { echo "$@" | tr '[A-Z]' '[a-z]'; }
    local -a opengl_libs=(
      'GL'
      'EGL'
      'GLESv1_CM'
      'GLESv2'
    )
    local opengl_lib
    local opengl_lib_lower
    for opengl_lib in "''${opengl_libs[@]}"; do
      opengl_lib_lower="$(tolower "$opengl_lib")"
      cat > "''${opengl_lib_lower}.pc" <<EOF
    Name: $opengl_lib_lower
    Description: Dummy $opengl_lib library
    Version: ${date}
    Libs: -L$out/lib -l$opengl_lib
    Cflags: -I${opengl-headers}/include -I${egl-headers}/include -I${mesa-headers}/include

    EOF
      install -D -m644 -v "''${opengl_lib_lower}.pc" \
        "$dummypc"/lib/pkgconfig/"''${opengl_lib_lower}.pc"
    done
  '';

  outputs = [
    "out"
    "dummypc"
  ];

  meta = with lib; {
    description = "The GL Vendor-Neutral Dispatch library";
    homepage = https://github.com/NVIDIA/libglvnd;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
