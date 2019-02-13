{ stdenv
, bison
, fetchTritonPatch
, fetchurl
, flex
, lib

, glib
, libffi
, python3

, cairo
}:

let
  inherit (lib)
    boolWt
    optionals
    optionalString;

  channel = "1.58";
  version = "${channel}.3";
in
stdenv.mkDerivation rec {
  name = "gobject-introspection-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gobject-introspection/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "025b632bbd944dcf11fc50d19a0ca086b83baf92b3e34936d008180d28cdc3c8";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  buildInputs = [
    glib
    libffi
    python3
  ] ++ optionals doCheck [
    cairo
  ];

  setupHook = ./setup-hook.sh;

  patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "gobject-introspection/gobject-introspection-1.x-absolute_shlib_path.patch";
      sha256 = "72be007720645946a4db10e4d845a78ef0d74867db915f414c1ec485f8a2494e";
    })
  ];

  postPatch = ''
    # Fix python patching
    grep -q 's,@PYTHON_CMD\\@,.*$(PYTHON),' Makefile.in
    sed -i 's#s,@PYTHON_CMD\\@,.*$(PYTHON),#s,@PYTHON_CMD\\@,$(PYTHON),#' Makefile.in
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-gtk-doc"
    "--disable-doctool"
  ];

  doCheck = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Url = "https://download.gnome.org/sources/gobject-introspection/"
          + "${channel}/${name}.sha256sum";
      };
    };
  };

  meta = with lib; {
    description = "A middleware layer between C libraries and language bindings";
    homepage = http://live.gnome.org/GObjectIntrospection;
    license = with licenses; [
      lgpl2Plus
      gpl2Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
