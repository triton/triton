{ stdenv
, fetchurl
, patchelf
}:

let
  inherit (stdenv.lib)
    makeSearchPath;

  libPath = makeSearchPath "lib" [
    stdenv.cc.libc
  ];

  version = "2.4.2";
in
stdenv.mkDerivation rec {
  name = "resilio-${version}";

  src  = fetchurl {
    url  = "https://download-cdn.resilio.com/${version}/"
      + "linux-x64/resilio-sync_x64.tar.gz";
    sha256 = "df7f3cf0d5fca711b0b97d446dd517f7a532e894ec33b7b052078d8cc8581580";
  };

  nativeBuildInputs = [
    patchelf
  ];

  sourceRoot = ".";

  installPhase = ''
    install -D -m755 -v rslsync $out/bin/rslsync
  '';

  preFixup = ''
    patchelf \
      --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}" \
      "$out/bin/rslsync"
  '';

  dontStrip = true;

  meta = with stdenv.lib; {
    description = "Automatically sync files via secure, distributed technology";
    homepage = https://www.resilio.com/individuals/;
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
