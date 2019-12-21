{ system ? builtins.currentSystem
}:
{
  lib = import lib { };
  builder = import builder { inherit lib; };
  pkgs = import pkgs { inherit system; };
}
