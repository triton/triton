{ pkgs }:
{
  inherit (pkgs)
    bash
    brotli
    bzip2
    coreutils
    diffutils
    findutils
    gawk
    gnugrep
    gnumake
    gnupatch
    gnused
    gnutar
    gzip
    pkgconfig
    xz;

  # We don't want to expose curl-config
  curl = pkgs.stdenv.mkDerivation {
    name = "curl-path";

    buildCommand = ''
      mkdir -p "$out/bin"
      ln -sv "${pkgs.curl}/bin/curl" "$out/bin"
    '';
  };
}
