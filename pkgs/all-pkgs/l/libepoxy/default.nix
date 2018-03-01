{ stdenv
, fetchurl
, lib
, meson
, ninja

, libx11
, opengl-dummy
, xproto
}:

let
  inherit (lib)
    replaceChars;

  channel = "1.5";
  version = "${channel}.0";

  versionFormatted =
    # For initial minor releases drop the trailing zero
    if replaceChars ["${channel}."] [""] version == "0" then
      channel
    else
      version;
in
stdenv.mkDerivation rec {
  name = "libepoxy-${version}";

  src = fetchurl {
    urls = [
      ("https://github.com/anholt/libepoxy/releases/download/v${versionFormatted}/"
        + "${name}.tar.xz")
      "mirror://gnome/sources/libepoxy/${channel}/${name}.tar.xz"
    ];
    hashOutput = false;
    sha256 = "4c94995398a6ebf691600dda2e9685a0cac261414175c2adf4645cdfab42a5d5";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  buildInputs = [
    libx11
    opengl-dummy
    xproto
  ];

  mesonFlags = [
    "-Denable-docs=false"
    "-Denable-glx=${if opengl-dummy.glx then "yes" else "no"}"
    "-Denable-egl=${if opengl-dummy.egl then "yes" else "no"}"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/libepoxy/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "A library for handling OpenGL function pointer management";
    homepage = https://github.com/anholt/libepoxy;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
