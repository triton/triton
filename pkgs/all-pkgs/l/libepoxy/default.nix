{ stdenv
, fetchurl
, lib
, python3

, mesa
, xorg
}:

let
  inherit (lib)
    replaceChars;

  channel = "1.4";
  version = "${channel}.3";

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
    sha256 = "0b808a06c9685a62fca34b680abb8bc7fb2fda074478e329b063c1f872b826f6";
  };

  nativeBuildInputs = [
    python3
    xorg.utilmacros
  ];

  buildInputs = [
    mesa
    xorg.libX11
  ];

  configureFlags = [
    "--enable-glx"
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
