{ stdenv
, fetchurl
}:

let
  sources = {
    "${stdenv.lib.head stdenv.lib.platforms.x86_64-linux}" = {
      sha1 = "d29b7607d13d64078b6324aec82926fb493f59ba";
      sha256 = "8deb8b687cb7d89ea943745c16c1061225fcbb5c64c0c121cdd1cb68673e683e";
      platform = "linux-x86_64";
    };
  };

  date = "2016-02-17";
  rev = "4d3eebf";
  
  inherit (sources."${stdenv.targetSystem}")
    platform
    sha1
    sha256;
in
stdenv.mkDerivation {
  name = "rustc-bootstrap-1.8.0";
  
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
