{ stdenv
, fetchurl
, lib
, patchelf
}:

let
  inherit (lib)
    makeSearchPath;

  libPath = makeSearchPath "lib" [
    stdenv.cc.libc
  ];

  version = "2.5.8";
in
stdenv.mkDerivation rec {
  name = "resilio-${version}";

  src  = fetchurl {
    url  = "https://download-cdn.resilio.com/${version}/"
      + "linux-x64/resilio-sync_x64.tar.gz";
    sha256 = "bf6f0077adbb5380e86a3e613453a85f7c2380883f0656e5fdc3cfed3e2b0098";
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
  # FIXME
  sourceDateEpochWarn = true;

  meta = with lib; {
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
