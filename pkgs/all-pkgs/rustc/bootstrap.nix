{ stdenv
, fetchurl
}:

let
  sources = {
    "${stdenv.lib.head stdenv.lib.platforms.x86_64-linux}" = {
      sha1 = "1273b6b6aed421c9e40c59f366d0df6092ec0397";
      sha256 = "a8ca657d78162a9f0a69a1ec8b0460e97259cdf2e6353ee256ae206876c9637e";
      platform = "linux-x86_64";
    };
  };

  date = "2016-03-18";
  rev = "235d774";
  
  inherit (sources."${stdenv.targetSystem}")
    platform
    sha1
    sha256;
in
stdenv.mkDerivation {
  name = "rustc-bootstrap-${date}";
  
  src = fetchurl {
    url = "https://static.rust-lang.org/stage0-snapshots/rust-stage0-${date}-${rev}-${platform}-${sha1}.tar.bz2";
    sha1Confirm = sha1;
    inherit sha256;
  };

  installPhase = ''
    mkdir -p "$out"
    cp -r bin "$out/bin"
    patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath "${stdenv.cc.cc}/lib" $out/bin/*
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
