{ pkgs }:
{
  inherit (pkgs) coreutils findutils diffutils gnused gnugrep gawk gnutar
    gzip bzip2 gnumake bash patch pkgconfig xz curl;
}
