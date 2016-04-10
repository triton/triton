{ callPackage, self, overrides ? {} }:

let
  overridden = set // overrides; set = with overridden; {

    libart_lgpl = callPackage ./platform/libart_lgpl { };

    gnome_vfs = callPackage ./platform/gnome-vfs { };

  };
in

overridden
