let

  attrsets = import ./attrsets.nix;
  customisation = import ./customisation.nix;
  debug = import ./debug.nix;
  licenses = import ./licenses.nix;
  lists = import ./lists.nix;
  maintainers = import ./maintainers.nix;
  meta = import ./meta.nix;
  misc = import ./deprecated.nix;
  modules = import ./modules.nix;
  options = import ./options.nix;
  platforms = import ./platforms.nix;
  sources = import ./sources.nix;
  strings = import ./strings.nix;
  stringsWithDeps = import ./strings-with-deps.nix;
  systems = import ./systems.nix;
  trivial = import ./trivial.nix;
  types = import ./types.nix;

in {
  inherit
    attrsets
    debug
    licenses
    lists
    maintainers
    meta
    modules
    options
    platforms
    sources
    strings
    stringsWithDeps
    systems
    trivial
    types;
}
# !!! don't include everything at top-level; perhaps only the most
# commonly used functions.
// attrsets
// customisation
// debug
// lists
// meta
// misc
// modules
// options
// sources
// strings
// stringsWithDeps
// systems
// trivial
// types
