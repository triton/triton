let
  lib = import ../../../lib;
in
lib.makeOverridable (

{ system
, name ? "stdenv"
, preHook ? ""
, initialPath
, cc
, shell
, allowedRequisites ? null
, extraArgs ? { }
, extraAttrs ? { }
, overrides ? (pkgs: { })
, config

, setupScript ? ./setup.sh

, extraBuildInputs ? [ ]
, __stdenvImpureHostDeps ? [ ]
, __extraImpureHostDeps ? [ ]
, stdenvSandboxProfile ? ""
, extraSandboxProfile ? ""
}:

let

  allowUnfree =
    config.allowUnfree or false
    || builtins.getEnv "NIXPKGS_ALLOW_UNFREE" == "1";

  allowBroken =
    config.allowBroken or false
    || builtins.getEnv "NIXPKGS_ALLOW_BROKEN" == "1";

  whitelist = config.whitelistedLicenses or [ ];
  blacklist = config.blacklistedLicenses or [ ];

  onlyLicenses =
    list:
    lib.lists.all (
      license:
      let
        l = lib.licenses.${license.shortName or "BROKEN"} or false;
      in
      if license == l then
        true
      else
        throw "‘${showLicense license}’ is not an attribute of lib.licenses"
    ) list;

  mutuallyExclusive =
    a: b:
    (builtins.length a) == 0 ||
    (!(builtins.elem (builtins.head a) b)
    && mutuallyExclusive (builtins.tail a) b);

  areLicenseListsValid =
    if mutuallyExclusive whitelist blacklist then
      assert onlyLicenses whitelist;
      assert onlyLicenses blacklist;
      true
    else
      throw "whitelistedLicenses and blacklistedLicenses are not mutually exclusive.";

  hasLicense =
    attrs:
    builtins.hasAttr "meta" attrs
    && builtins.hasAttr "license" attrs.meta;

  hasWhitelistedLicense =
    assert areLicenseListsValid;
    attrs:
    hasLicense attrs
    && builtins.elem attrs.meta.license whitelist;

  hasBlacklistedLicense =
    assert areLicenseListsValid;
    attrs:
    hasLicense attrs
    && builtins.elem attrs.meta.license blacklist;

  isUnfree =
    licenses:
    lib.lists.any (l:
      !l.free or true
      || l == "unfree"
      || l == "unfree-redistributable"
    ) licenses;

  # Alow granular checks to allow only some unfree packages
  # Example:
  # {pkgs, ...}:
  # {
  #   allowUnfree = false;
  #   allowUnfreePredicate = (x: pkgs.lib.hasPrefix "flashplayer-" x.name);
  # }
  allowUnfreePredicate = config.allowUnfreePredicate or (x: false);

  # Check whether unfree packages are allowed and if not, whether the
  # package has an unfree license and is not explicitely allowed by the
  # `allowUNfreePredicate` function.
  hasDeniedUnfreeLicense =
    attrs:
    !allowUnfree
    && hasLicense attrs
    && isUnfree (lib.lists.toList attrs.meta.license)
    && !allowUnfreePredicate attrs;

  showLicense =
    license:
    license.shortName or "unknown";

  defaultNativeBuildInputs = [
    ../../build-support/setup-hooks/move-docs.sh
    ../../build-support/setup-hooks/move-sbin.sh
    ../../build-support/setup-hooks/move-lib64.sh
    ../../build-support/setup-hooks/compress-man-pages.sh
    ../../build-support/setup-hooks/pkgconfig.sh
    ../../build-support/setup-hooks/strip.sh
    ../../build-support/setup-hooks/patch-shebangs.sh
    ../../build-support/setup-hooks/absolute-libtool.sh # Must come after any $prefix/lib manipulations
    ../../build-support/setup-hooks/absolute-pkgconfig.sh # Must come after any $prefix/lib manipulations
    ../../build-support/setup-hooks/set-source-date-epoch-to-latest.sh
    cc
  ] ++ extraBuildInputs;

  # Add a utility function to produce derivations that use this
  # stdenv and its shell.
  mkDerivation = {
    buildInputs ? [ ]
    , nativeBuildInputs ? [ ]
    , propagatedBuildInputs ? [ ]
    , propagatedNativeBuildInputs ? [ ]
    , crossConfig ? null
    , meta ? { }
    , passthru ? { }
    , pos ? null # position used in error messages and for meta.position
    , separateDebugInfo ? false
    , outputs ? [ "out" ]
    , __impureHostDeps ? [ ]
    , __propagatedImpureHostDeps ? [ ]
    , sandboxProfile ? ""
    , propagatedSandboxProfile ? ""
    , ...
  } @ attrs:
    let
      pos' =
        if pos != null then
          pos
        else if attrs.meta.description or null != null then
          builtins.unsafeGetAttrPos "description" attrs.meta
        else
          builtins.unsafeGetAttrPos "name" attrs;
      pos'' =
        if pos' != null then
          "‘" + pos'.file + ":" + toString pos'.line + "’"
        else
          "«unknown-file»";

      throwEvalHelp = { reason, errormsg }:
        # uppercase the first character of string s
        let
          up = s:
          with lib;
          let
            cs = lib.stringToCharacters s;
          in
          concatStrings (singleton (toUpper (head cs)) ++ tail cs);
        in
        assert builtins.elem reason [
          "unfree"
          "broken"
          "blacklisted"
        ];

        throw ("Package ‘${attrs.name or "«name-missing»"}’ in ${pos''} ${errormsg}, refusing to evaluate."
        + (lib.strings.optionalString (reason != "blacklisted") ''

          a) For `nixos-rebuild` you can set
            { nixpkgs.config.allow${up reason} = true; }
          in configuration.nix to override this.

          b) For `nix-env`, `nix-build` or any other Nix command you can add
            { allow${up reason} = true; }
          to ~/.nixpkgs/config.nix.
        ''));

      # Check if a derivation is valid, that is whether it passes checks for
      # e.g brokenness or license.
      #
      # Return { valid: Bool } and additionally
      # { reason: String; errormsg: String } if it is not valid, where
      # reason is one of "unfree", "blacklisted" or "broken".
      checkValidity =
        attrs:
        if hasDeniedUnfreeLicense attrs && !(hasWhitelistedLicense attrs) then {
          valid = false;
          reason = "unfree";
          errormsg = "has an unfree license (‘${showLicense attrs.meta.license}’)";
        } else if hasBlacklistedLicense attrs then {
          valid = false;
          reason = "blacklisted";
          errormsg = "has a blacklisted license (‘${showLicense attrs.meta.license}’)";
        } else if !allowBroken && attrs.meta.broken or false then {
          valid = false;
          reason = "broken";
          errormsg = "is marked as broken";
        } else if !allowBroken && attrs.meta.platforms or null != null &&
                  !lib.lists.elem result.system attrs.meta.platforms then {
          valid = false;
          reason = "broken";
          errormsg = "is not supported on ‘${result.system}’";
        } else {
          valid = true;
        };

      outputs' =
        outputs
        ++ (if separateDebugInfo then
              assert result.isLinux; [ "debug" ]
            else
              [ ]);

      buildInputs' =
        buildInputs
        ++ (if separateDebugInfo then [
              ../../build-support/setup-hooks/separate-debug-info.sh
            ] else
              [ ]);
    in

    # Throw an error if trying to evaluate an non-valid derivation
    assert
      let
        v = checkValidity attrs;
      in
      if !v.valid then
        throwEvalHelp (removeAttrs v [ "valid" ])
      else
        true;

    lib.addPassthru (derivation (
      (removeAttrs attrs [
        "meta"
        "passthru"
        "crossAttrs"
        "pos"
        "__impureHostDeps"
        "__propagatedImpureHostDeps"
        "sandboxProfile"
        "propagatedSandboxProfile"
      ]) // (
    let
      computedSandboxProfile =
        lib.concatMap (
          input:
          input.__propagatedSandboxProfile or [ ]
        ) (extraBuildInputs ++ buildInputs ++ nativeBuildInputs);
      computedPropagatedSandboxProfile =
        lib.concatMap (
          input:
          input.__propagatedSandboxProfile or [ ]
        ) (propagatedBuildInputs ++ propagatedNativeBuildInputs);
      computedImpureHostDeps =
        lib.unique (
          lib.concatMap (
            input:
            input.__propagatedImpureHostDeps or [ ]
          ) (extraBuildInputs ++ buildInputs ++ nativeBuildInputs)
        );
      computedPropagatedImpureHostDeps =
        lib.unique (
          lib.concatMap (
            input:
            input.__propagatedImpureHostDeps or [ ]
          ) (propagatedBuildInputs ++ propagatedNativeBuildInputs)
        );
    in {
      builder = attrs.realBuilder or shell;
      args = attrs.args or ["-e" (attrs.builder or ./default-builder.sh)];
      stdenv = result;
      system = result.system;
      userHook = config.stdenv.userHook or null;
      __ignoreNulls = true;

      # Inputs built by the cross compiler.
      buildInputs =
        if crossConfig != null then
          buildInputs'
        else
          [ ];
      propagatedBuildInputs =
        if crossConfig != null then
          propagatedBuildInputs
        else
          [ ];
      # Inputs built by the usual native compiler.
      nativeBuildInputs =
        nativeBuildInputs ++ (
          if crossConfig == null then
            buildInputs'
          else [ ]);
      propagatedNativeBuildInputs =
        propagatedNativeBuildInputs ++ (
          if crossConfig == null then
            propagatedBuildInputs
          else [ ]);
    } // (if outputs' != [ "out" ] then {
      outputs = outputs';
    } else { })))) (
      {
        # The meta attribute is passed in the resulting attribute set,
        # but it's not part of the actual derivation, i.e., it's not
        # passed to the builder and is not a dependency.  But since we
        # include it in the result, it *is* available to nix-env for
        # queries.  We also a meta.position attribute here to
        # identify the source location of the package.
        meta = meta // (if pos' != null then {
          position = pos'.file + ":" + toString pos'.line;
        } else {});
        inherit passthru;
      } //
      # Pass through extra attributes that are not inputs, but
      # should be made available to Nix expressions using the
      # derivation (e.g., in assertions).
      passthru);

  # The stdenv that we are producing.
  result =
    derivation (
    (if isNull allowedRequisites then
       { }
     else {
       allowedRequisites =
        allowedRequisites ++
        defaultNativeBuildInputs;
     }) // {
      inherit
        system
        name;

      builder = shell;

      args = [ "-e" ./builder.sh ];

      setup = setupScript;

      inherit
        preHook
        initialPath
        shell
        defaultNativeBuildInputs;
    }
    // extraArgs)

    // rec {

      meta.description =
        "The default build environment for Unix packages in Nixpkgs";

      # Utility flags to test the type of platform.
      isLinux =
        system == "i686-linux"
        || system == "x86_64-linux";
      isFreeBSD =
        system == "i686-freebsd"
        || system == "x86_64-freebsd";
      isi686 =
        system == "i686-linux"
        || system == "i686-freebsd";
      isx86_64 =
        system == "x86_64-linux"
        || system == "x86_64-freebsd";
      is64bit =
        system == "x86_64-linux"
        || system == "x86_64-freebsd";

      shouldUsePkg = lib.shouldUsePkgSystem system;

      # Whether we should run paxctl to pax-mark binaries.
      needsPax = false;

      inherit mkDerivation;

      # For convenience, bring in the library functions in lib/ so
      # packages don't have to do that themselves.
      inherit lib;

      inherit overrides;

      inherit cc;
    }

    # Propagate any extra attributes.  For instance, we use this to
    # "lift" packages like curl from the final stdenv for Linux to
    # all-packages.nix for that platform (meaning that it has a line
    # like curl = if stdenv ? curl then stdenv.curl else ...).
    // extraAttrs;

in result)
