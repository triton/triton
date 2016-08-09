## Configuration:
# Control you default wine config in nixpkgs-config:
# wine = {
#   release = "stable"; # "stable", "unstable", "staging"
#   build = "wineWow"; # "wine32", "wine64", "wineWow"
# };
# Make additional configurations on demand:
# wine.override { wineBuild = "wine32"; wineRelease = "staging"; };
{ stdenv, lib, pkgs, callPackage,
  wineRelease ? "stable",
  wineBuild ? (if lib.elem stdenv.targetSystem lib.platforms.x86_64-linux then "wineWow" else "wine32"),
  pulseaudioSupport ? false,
  libtxc_dxtn_Name ? "libtxc_dxtn_s2tc" }:

let wine-build = build: release:
      lib.getAttr build (callPackage ./packages.nix {
        wineRelease = release;
        inherit pulseaudioSupport;
      });

in if wineRelease == "staging" then
  callPackage ./staging.nix {
    inherit libtxc_dxtn_Name;
    wineUnstable = wine-build wineBuild "unstable";
  }
else
  wine-build wineBuild wineRelease
