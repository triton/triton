{ supportedSystems
, allPackages
, allowTexliveBuilds ? false
, scrubJobs ? true
}:

with import ../../lib;

let
  allPackages' = args: allPackages args // {
    config = {
      allowUnfree = false;
      inHydra = true;
      inherit allowTexliveBuilds;
    };
    stdenv = null;
  };

  pkgs_x86_64-linux = allPackages' {
    targetSystem = "x86_64-linux";
    hostSystem = "x86_64-linux";
  };
  pkgs_i686-linux = allPackages' {
    targetSystem = "i686-linux";
    hostSystem = "x86_64-linux";
  };
in
rec {
  /* !!! Hack: poor man's memoisation function.  Necessary to prevent
     Nixpkgs from being evaluated again and again for every
     job/platform pair. */
  pkgsFor = { targetSystem, hostSystem }:
    if targetSystem == "x86_64-linux" && hostSystem == "x86_64-linux" then
      pkgs_x86_64-linux
    else if targetSystem == "i686-linux" && hostSystem == "i686-linux" then
      pkgs_i686-linux
    else
      abort "unsupported system type: ${targetSystem} built by ${hostSystem}";

  hydraJob' = if scrubJobs then hydraJob else id;

  /* Build a package on the given set of platforms.  The function `f'
     is called for each supported platform with Nixpkgs for that
     platform as an argument .  We return an attribute set containing
     a derivation for each supported platform, i.e. ‘{ x86_64-linux =
     f pkgs_x86_64_linux; i686-linux = f pkgs_i686_linux; ... }’. */
  testOn = systems: f: genAttrs
    (filter (x: elem x supportedSystems) systems) (system: hydraJob' (f (pkgsFor system)));

  /* Given a nested set where the leaf nodes are lists of platforms,
     map each leaf node to `testOn [platforms...] (pkgs:
     pkgs.<attrPath>)'. */
  mapTestOn = mapAttrsRecursive
    (path: systems: testOn systems (pkgs: getAttrFromPath path pkgs));

  /* Recursively map a (nested) set of derivations to an isomorphic
     set of meta.platforms values. */
  packagePlatforms = mapAttrs (name: value:
    let res = builtins.tryEval (
      if isDerivation value then
        value.meta.hydraPlatforms or (value.meta.platforms or [])
      else if value.recurseForDerivations or false || value.recurseForRelease or false then
        packagePlatforms value
      else
        []);
    in if res.success then res.value else []
    );
}
