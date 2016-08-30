/* This file composes the Nix Packages collection.  That is, it
   imports the functions that build the various packages, and calls
   them with appropriate arguments.  The result is a set of all the
   packages in the Nix Packages collection for some particular
   platform. */


{ targetSystem
, hostSystem

# Allow a configuration attribute set to be passed in as an
# argument.  Otherwise, it's read from $NIXPKGS_CONFIG or
# ~/.nixpkgs/config.nix.
, config

# Allows the standard environment to be swapped out
# This is typically most useful for bootstrapping
, stdenv
} @ args:

let

  lib = import ../../lib;

  # The contents of the configuration file found at $NIXPKGS_CONFIG or
  # $HOME/.nixpkgs/config.nix.
  # for NIXOS (nixos-rebuild): use nixpkgs.config option
  config =
    if args.config != null then
      args.config
    else if builtins.getEnv "NIXPKGS_CONFIG" != "" then
      import (builtins.toPath (builtins.getEnv "NIXPKGS_CONFIG")) { inherit pkgs; }
    else
      let
        home = builtins.getEnv "HOME";
        homePath =
          if home != "" then
            builtins.toPath (home + "/.nixpkgs/config.nix")
          else
            null;
      in
        if homePath != null && builtins.pathExists homePath then
          import homePath { inherit pkgs; }
        else
          { };

  # Helper functions that are exported through `pkgs'.
  helperFunctions =
    stdenvAdapters //
    (import ../build-support/trivial-builders.nix { inherit lib; inherit (pkgs) stdenv; inherit (pkgs.xorg) lndir; });

  stdenvAdapters =
    import ../stdenv/adapters.nix pkgs;


  # Allow packages to be overriden globally via the `packageOverrides'
  # configuration option, which must be a function that takes `pkgs'
  # as an argument and returns a set of new or overriden packages.
  # The `packageOverrides' function is called with the *original*
  # (un-overriden) set of packages, allowing packageOverrides
  # attributes to refer to the original attributes (e.g. "foo =
  # ... pkgs.foo ...").
  pkgs = applyGlobalOverrides (config.packageOverrides or (pkgs: {}));

  mkOverrides = pkgsOrig: overrides: overrides //
        (lib.optionalAttrs (pkgsOrig.stdenv ? overrides) (pkgsOrig.stdenv.overrides pkgsOrig));

  # Return the complete set of packages, after applying the overrides
  # returned by the `overrider' function (see above).  Warning: this
  # function is very expensive!
  applyGlobalOverrides = overrider:
    let
      # Call the overrider function.  We don't want stdenv overrides
      # in the case of cross-building, or otherwise the basic
      # overrided packages will not be built with the crossStdenv
      # adapter.
      overrides = mkOverrides pkgsOrig (overrider pkgsOrig);

      # The un-overriden packages, passed to `overrider'.
      pkgsOrig = pkgsFun pkgs {};

      # The overriden, final packages.
      pkgs = pkgsFun pkgs overrides;
    in pkgs;


  # The package compositions.  Yes, this isn't properly indented.
  pkgsFun = pkgs: overrides:
    with helperFunctions;
    let defaultScope = pkgs; self = self_ // overrides;
    self_ =
      let
        inherit (self_)
          callPackage
          callPackages
          callPackageAlias
          recurseIntoAttrs
          wrapCCWith
          wrapCC;
        inherit (lib)
          hiPrio
          hiPrioSet
          lowPrio
          lowPrioSet;
      in
     helperFunctions // {

  # Make some arguments passed to all-packages.nix available
  targetSystem = args.targetSystem;
  hostSystem = args.hostSystem;

  # Allow callPackage to fill in the pkgs argument
  inherit pkgs;


  # We use `callPackage' to be able to omit function arguments that
  # can be obtained from `pkgs' or `pkgs.xorg' (i.e. `defaultScope').
  # Use `newScope' for sets of packages in `pkgs' (see e.g. `gnome'
  # below).
  callPackage = self_.newScope {};

  callPackages = lib.callPackagesWith defaultScope;

  newScope = extra: lib.callPackageWith (defaultScope // extra);

  callPackageAlias = package: newAttrs: pkgs."${package}".override newAttrs;

  # Easily override this package set.
  # Warning: this function is very expensive and must not be used
  # from within the nixpkgs repository.
  #
  # Example:
  #  pkgs.overridePackages (self: super: {
  #    foo = super.foo.override { ... };
  #  }
  #
  # The result is `pkgs' where all the derivations depending on `foo'
  # will use the new version.
  overridePackages = f:
    let
      newpkgs = pkgsFun newpkgs overrides;
      overrides = mkOverrides pkgs (f newpkgs pkgs);
    in newpkgs;

  # Override system. This is useful to build i686 packages on x86_64-linux.
  forceSystem = { targetSystem, hostSystem }: (import ./all-packages.nix) {
    inherit targetSystem hostSystem config stdenv;
  };

  pkgs_32 =
    let
      hostSystem' =
        if [ hostSystem ] == lib.platforms.x86_64-linux && [ targetSystem' ] == lib.platforms.i686-linux then
          lib.head lib.platforms.i686-linux
        else if [ hostSystem ] == lib.platforms.i686-linux && [ targetSystem' ] == lib.platforms.i686-linux then
          lib.head lib.platforms.i686-linux
        else
          throw "Couldn't determine the 32 bit host system.";

      targetSystem' =
        if [ targetSystem ] == lib.platforms.x86_64-linux then
          lib.head lib.platforms.i686-linux
        else if [ targetSystem ] == lib.platforms.i686-linux then
          lib.head lib.platforms.i686-linux
        else
          throw "Couldn't determine the 32 bit target system.";
    in pkgs.forceSystem {
      hostSystem = hostSystem';
      targetSystem = targetSystem';
    };

  # For convenience, allow callers to get the path to Nixpkgs.
  path = ../..;

  ### Helper functions.
  inherit lib config stdenvAdapters;

  # Applying this to an attribute set will cause nix-env to look
  # inside the set for derivations.
  recurseIntoAttrs = attrs: attrs // { recurseForDerivations = true; };

  #builderDefs = lib.composedArgsAndFun (callPackage ../build-support/builder-defs/builder-defs.nix) {};

  #builderDefsPackage = builderDefs.builderDefsPackage builderDefs;

  stringsWithDeps = lib.stringsWithDeps;


  ### Nixpkgs maintainer tools

  nix-generate-from-cpan = callPackage ../../maintainers/scripts/nix-generate-from-cpan.nix { };

  nixpkgs-lint = callPackage ../../maintainers/scripts/nixpkgs-lint.nix { };


  ### STANDARD ENVIRONMENT

  stdenv =
    if args.stdenv != null then
      args.stdenv
    else
      import ../stdenv {
        allPackages = args': import ./all-packages.nix (args // args');
        inherit lib targetSystem hostSystem config;
      };

  ### BUILD SUPPORT

  attrSetToDir = arg: callPackage ../build-support/upstream-updater/attrset-to-dir.nix {
    theAttrSet = arg;
  };

  autoreconfHook = makeSetupHook
    { substitutions = { inherit (pkgs) autoconf automake gettext libtool; }; }
    ../build-support/setup-hooks/autoreconf.sh;

  ensureNewerSourcesHook = { year }: makeSetupHook {}
    (writeScript "ensure-newer-sources-hook.sh" ''
      postUnpackHooks+=(_ensureNewerSources)
      _ensureNewerSources() {
        '${pkgs.findutils}/bin/find' "$sourceRoot" \
          '!' -newermt '${year}-01-01' -exec touch -h -d '${year}-01-02' '{}' '+'
      }
    '');

  buildEnv = callPackage ../build-support/buildenv { }; # not actually a package

  #buildFHSEnv = callPackage ../build-support/build-fhs-chrootenv/env.nix { };

  chrootFHSEnv = callPackage ../build-support/build-fhs-chrootenv { };
  userFHSEnv = callPackage ../build-support/build-fhs-userenv { };

  #buildFHSChrootEnv = args: chrootFHSEnv {
  #  env = buildFHSEnv (removeAttrs args [ "extraInstallCommands" ]);
  #  extraInstallCommands = args.extraInstallCommands or "";
  #};

  #buildFHSUserEnv = args: userFHSEnv {
  #  env = buildFHSEnv (removeAttrs args [ "runScript" "extraBindMounts" "extraInstallCommands" "meta" ]);
  #  runScript = args.runScript or "bash";
  #  extraBindMounts = args.extraBindMounts or [];
  #  extraInstallCommands = args.extraInstallCommands or "";
  #  importMeta = args.meta or {};
  #};

  #buildMaven = callPackage ../build-support/build-maven.nix {};

  cmark = callPackage ../development/libraries/cmark { };

  #dockerTools = callPackage ../build-support/docker { };

  #dotnetenv = callPackage ../build-support/dotnetenv {
  #  dotnetfx = dotnetfx40;
  #};

  #dotnetbuildhelpers = callPackage ../build-support/dotnetbuildhelpers {
  #  inherit helperFunctions;
  #};

  fetchbower = callPackage ../build-support/fetchbower {
    inherit (nodePackages) fetch-bower;
  };

  fetchbzr = callPackage ../build-support/fetchbzr { };

  #fetchcvs = callPackage ../build-support/fetchcvs { };

  #fetchdarcs = callPackage ../build-support/fetchdarcs { };

  fetchgit = callPackage ../build-support/fetchgit { };

  fetchgitPrivate = callPackage ../build-support/fetchgit/private.nix { };

  fetchgitrevision = import ../build-support/fetchgitrevision runCommand pkgs.git;

  fetchgitLocal = callPackage ../build-support/fetchgitlocal { };

  #packer = callPackage ../development/tools/packer { };

  fetchpatch = callPackage ../build-support/fetchpatch { };

  fetchsvn = callPackage ../build-support/fetchsvn {
    sshSupport = true;
  };

  fetchsvnrevision = import ../build-support/fetchsvnrevision runCommand pkgs.subversion;

  fetchsvnssh = callPackage ../build-support/fetchsvnssh {
    sshSupport = true;
  };

  fetchhg = callPackage ../build-support/fetchhg { };

  # `fetchurl' downloads a file from the network.
  fetchurl = callPackage ../build-support/fetchurl { };

  fetchTritonPatch = { rev, file, sha256 }: pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/triton/triton-patches/${rev}/${file}";
    allowHashOutput = false;
    inherit sha256;
  };

  fetchzip = callPackage ../build-support/fetchzip { };

  fetchFromGitHub = { owner, repo, rev, sha256, name ? "${repo}-${rev}" }: pkgs.fetchzip {
    inherit name sha256;
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    meta.homepage = "https://github.com/${owner}/${repo}/";
  } // { inherit rev; };

  fetchFromBitbucket = { owner, repo, rev, sha256, name ? "${repo}-${rev}" }: pkgs.fetchzip {
    inherit name sha256;
    url = "https://bitbucket.org/${owner}/${repo}/get/${rev}.tar.gz";
    meta.homepage = "https://bitbucket.org/${owner}/${repo}/";
    extraPostFetch = ''
      find . -name .hg_archival.txt -delete
    ''; # impure file; see #12002
  };

  # cgit example, snapshot support is optional in cgit
  fetchFromSavannah = { repo, rev, sha256, name ? "${repo}-${rev}" }: pkgs.fetchzip {
    inherit name sha256;
    url = "http://git.savannah.gnu.org/cgit/${repo}.git/snapshot/${repo}-${rev}.tar.gz";
    meta.homepage = "http://git.savannah.gnu.org/cgit/${repo}.git/";
  };

  # gitlab example
  fetchFromGitLab = { owner, repo, rev, sha256, name ? "${repo}-${rev}" }: pkgs.fetchzip {
    inherit name sha256;
    url = "https://gitlab.com/${owner}/${repo}/repository/archive.tar.gz?ref=${rev}";
    meta.homepage = "https://gitlab.com/${owner}/${repo}/";
  };

  # gitweb example, snapshot support is optional in gitweb
  fetchFromRepoOrCz = { repo, rev, sha256, name ? "${repo}-${rev}" }: pkgs.fetchzip {
    inherit name sha256;
    url = "http://repo.or.cz/${repo}.git/snapshot/${rev}.tar.gz";
    meta.homepage = "http://repo.or.cz/${repo}.git/";
  };

  fetchFromSourceforge = { repo, rev, sha256, name ? "${repo}-${rev}" }: pkgs.fetchzip {
    inherit name sha256;
    url = "http://sourceforge.net/code-snapshots/git/"
      + "${lib.substring 0 1 repo}/"
      + "${lib.substring 0 2 repo}/"
      + "${repo}/code.git/"
      + "${repo}-code-${rev}.zip";
    meta.homepage = "http://sourceforge.net/p/${repo}/code";
    preFetch = ''
      echo "Telling sourceforge to generate code tarball..."
      $curl --data "path=&" "http://sourceforge.net/p/${repo}/code/ci/${rev}/tarball" >/dev/null
      local found
      found=0
      for i in {1..30}; do
        echo "Checking tarball generation status..." >&2
        status="$($curl "http://sourceforge.net/p/${repo}/code/ci/${rev}/tarball_status?path=")"
        echo "$status"
        if echo "$status" | grep -q '{"status": "complete"}'; then
          found=1
          break
        fi
        if ! echo "$status" | grep -q '{"status": "\(ready\|busy\)"}'; then
          break
        fi
        sleep 1
      done
      if [ "$found" -ne "1" ]; then
        echo "Sourceforge failed to generate tarball"
        exit 1
      fi
    '';
  };

#  fetchNuGet = callPackage ../build-support/fetchnuget { };
#  buildDotnetPackage = callPackage ../build-support/build-dotnet-package { };

  resolveMirrorURLs = {url}: pkgs.fetchurl {
    showURLs = true;
    inherit url;
  };

  libredirect = callPackage ../build-support/libredirect { };

  makeDesktopItem = callPackage ../build-support/make-desktopitem { };

  makeAutostartItem = callPackage ../build-support/make-startupitem { };

  makeInitrd = { contents, compressor ? "gzip -9n", prepend ? [ ] }:
    callPackage ../build-support/kernel/make-initrd.nix {
      inherit contents compressor prepend;
    };

  makeWrapper = makeSetupHook { } ../build-support/setup-hooks/make-wrapper.sh;

  makeModulesClosure = { kernel, rootModules, allowMissing ? false }:
    callPackage ../build-support/kernel/modules-closure.nix {
      inherit kernel rootModules allowMissing;
    };

  pathsFromGraph = ../build-support/kernel/paths-from-graph.pl;

  srcOnly = args: callPackage ../build-support/src-only args;

  substituteAll = callPackage ../build-support/substitute/substitute-all.nix { };

  substituteAllFiles = callPackage ../build-support/substitute-files/substitute-all-files.nix { };

  replaceDependency = callPackage ../build-support/replace-dependency.nix { };

  nukeReferences = callPackage ../build-support/nuke-references/default.nix { };

  vmTools = callPackage ../build-support/vm/default.nix { };

  releaseTools = callPackage ../build-support/release/default.nix { };

  composableDerivation = callPackage ../../lib/composable-derivation.nix { };

  #platforms = import ./platforms.nix;

  setJavaClassPath = makeSetupHook { } ../build-support/setup-hooks/set-java-classpath.sh;

  keepBuildTree = makeSetupHook { } ../build-support/setup-hooks/keep-build-tree.sh;

  enableGCOVInstrumentation = makeSetupHook { } ../build-support/setup-hooks/enable-coverage-instrumentation.sh;

  makeGCOVReport = makeSetupHook
    { deps = [ pkgs.lcov pkgs.enableGCOVInstrumentation ]; }
    ../build-support/setup-hooks/make-coverage-analysis-report.sh;

  # intended to be used like nix-build -E 'with <nixpkgs> {}; enableDebugging fooPackage'
  enableDebugging = pkg: pkg.override { stdenv = stdenvAdapters.keepDebugInfo pkgs.stdenv; };

  findXMLCatalogs = makeSetupHook { } ../build-support/setup-hooks/find-xml-catalogs.sh;

  wrapGAppsHook = makeSetupHook {
    deps = [ makeWrapper ];
  } ../build-support/setup-hooks/wrap-gapps-hook.sh;

  separateDebugInfo = makeSetupHook { } ../build-support/setup-hooks/separate-debug-info.sh;

################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
############################# BEGIN ALL BUILDERS ###############################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################


wrapCCWith = ccWrapper: libc: extraBuildCommands: baseCC: ccWrapper {
  nativeTools = pkgs.stdenv.cc.nativeTools or false;
  nativeLibc = pkgs.stdenv.cc.nativeLibc or false;
  nativePrefix = pkgs.stdenv.cc.nativePrefix or "";
  cc = baseCC;
  isGNU = baseCC.isGNU or false;
  isClang = baseCC.isClang or false;
  inherit libc extraBuildCommands;
};

wrapCC = wrapCCWith (callPackage ../build-support/cc-wrapper) pkgs.stdenv.cc.libc "";

################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
############################## END ALL BUILDERS ################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################

################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
############################### BEGIN ALL PKGS #################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################

accountsservice = callPackage ../all-pkgs/a/accountsservice { };

acl = callPackage ../all-pkgs/a/acl { };

acpid = callPackage ../all-pkgs/a/acpid { };

adns = callPackage ../all-pkgs/a/adns { };

adwaita-icon-theme_3-20 = callPackage ../all-pkgs/a/adwaita-icon-theme {
  channel = "3.20";
};
adwaita-icon-theme = callPackageAlias "adwaita-icon-theme_3-20" { };

alsa-firmware = callPackage ../all-pkgs/a/alsa-firmware { };

alsa-lib = callPackage ../all-pkgs/a/alsa-lib { };

alsa-plugins = callPackage ../all-pkgs/a/alsa-plugins { };

alsa-utils = callPackage ../all-pkgs/a/alsa-utils { };

amrnb = callPackage ../all-pkgs/a/amrnb { };

amrwb = callPackage ../all-pkgs/a/amrwb { };

appdata-tools = callPackage ../all-pkgs/a/appdata-tools { };

appstream-glib = callPackage ../all-pkgs/a/appstream-glib { };

apr = callPackage ../all-pkgs/a/apr { };

apr-util = callPackage ../all-pkgs/a/apr-util { };

#ardour =  callPackage ../all-pkgs/a/ardour { };

argyllcms = callPackage ../all-pkgs/a/argyllcms { };

aria2 = callPackage ../all-pkgs/a/aria2 { };
aria = callPackageAlias "aria2" { };

arkive = callPackage ../all-pkgs/a/arkive { };

asciidoc = callPackage ../all-pkgs/a/asciidoc { };

asciinema = pkgs.python3Packages.asciinema;

aspell = callPackage ../all-pkgs/a/aspell { };

at-spi2-atk_2-20 = callPackage ../all-pkgs/a/at-spi2-atk {
  channel = "2.20";
};
at-spi2-atk = callPackageAlias "at-spi2-atk_2-20" { };

at-spi2-core_2-20 = callPackage ../all-pkgs/a/at-spi2-core {
  channel = "2.20";
};
at-spi2-core = callPackageAlias "at-spi2-core_2-20" { };

atk_2-20 = callPackage ../all-pkgs/a/atk {
  channel = "2.20";
};
atk = callPackageAlias "atk_2-20" { };

atkmm_2-24 = callPackage ../all-pkgs/a/atkmm {
  channel = "2.24";
};
atkmm = callPackageAlias "atkmm_2-24" { };

attr = callPackage ../all-pkgs/a/attr { };

audiofile = callPackage ../all-pkgs/a/audiofile { };

audit_full = callPackage ../all-pkgs/a/audit { };

audit_lib = callPackageAlias "audit_full" {
  prefix = "lib";
};

augeas = callPackage ../all-pkgs/a/augeas { };

autoconf = callPackage ../all-pkgs/a/autoconf { };

autoconf_21x = callPackageAlias "autoconf" {
  channel = "2.1x";
};

autogen = callPackage ../all-pkgs/a/autogen { };

automake = callPackage ../all-pkgs/a/automake { };

avahi = callPackage ../all-pkgs/a/avahi { };

babl = callPackage ../all-pkgs/b/babl { };

bash = callPackage ../all-pkgs/b/bash { };

bash-completion = callPackage ../all-pkgs/b/bash-completion { };

bc = callPackage ../all-pkgs/b/bc { };

bcache-tools = callPackage ../all-pkgs/b/bcache-tools { };

bcache-tools_dev = callPackageAlias "bcache-tools" {
  channel = "dev";
};

bison = callPackage ../all-pkgs/b/bison { };

bluez = callPackage ../all-pkgs/b/bluez { };

boehm-gc = callPackage ../all-pkgs/b/boehm-gc { };

boost155 = callPackage ../all-pkgs/b/boost/1.55.nix { };
boost161 = callPackage ../all-pkgs/b/boost/1.61.nix { };
boost = callPackageAlias "boost161" { };

brotli = callPackage ../all-pkgs/b/brotli { };

bs1770gain = callPackage ../all-pkgs/b/bs1770gain { };

btrfs-progs = callPackage ../all-pkgs/b/btrfs-progs { };

btsync = callPackage ../all-pkgs/b/btsync { };

bzip2 = callPackage ../all-pkgs/b/bzip2 { };

c-ares = callPackage ../all-pkgs/c/c-ares { };

cairo = callPackage ../all-pkgs/c/cairo { };

cairomm = callPackage ../all-pkgs/c/cairomm { };

caribou = callPackage ../all-pkgs/c/caribou { };

ccid = callPackage ../all-pkgs/c/ccid { };

cdparanoia = callPackage ../all-pkgs/c/cdparanoia { };

cdrtools = callPackage ../all-pkgs/c/cdrtools { };

# Only ever add ceph LTS releases
# The default channel should be the latest LTS
# Dev should always point to the latest versioned release
ceph_lib = pkgs.ceph.lib;
ceph = hiPrio (callPackage ../all-pkgs/c/ceph { });
ceph_0_94 = callPackage ../all-pkgs/c/ceph {
  channel = "0.94";
};
ceph_9 = callPackage ../all-pkgs/c/ceph {
  channel = "9";
};
ceph_10 = callPackage ../all-pkgs/c/ceph {
  channel = "10";
};
ceph_dev = callPackage ../all-pkgs/c/ceph/cmake.nix {
  channel = "dev";
};
ceph_git = callPackage ../all-pkgs/c/ceph/cmake.nix {
  channel = "git";
};

cgit = callPackage ../all-pkgs/c/cgit { };

cgmanager = callPackage ../all-pkgs/c/cgmanager { };

check = callPackage ../all-pkgs/c/check { };

chromaprint = callPackage ../all-pkgs/c/chromaprint { };

chromium = callPackage ../all-pkgs/c/chromium {
  channel = "stable";
};
chromium_beta = callPackageAlias "chromium" {
  channel = "beta";
};
chromium_dev = callPackageAlias "chromium" {
  channel = "dev";
};

cifs-utils = callPackage ../all-pkgs/c/cifs-utils { };

civetweb = callPackage ../all-pkgs/c/civetweb { };

cjdns = callPackage ../all-pkgs/c/cjdns { };

clang = wrapCC (callPackageAlias "llvm" { });

clutter_1-26 = callPackage ../all-pkgs/c/clutter {
  channel = "1.26";
};
clutter = callPackageAlias "clutter_1-26" { };

clutter-gst_2 = callPackage ../all-pkgs/c/clutter-gst {
  channel = "2.0";
};
clutter-gst_3 = callPackage ../all-pkgs/c/clutter-gst {
  channel = "3.0";
};
clutter-gst = callPackageAlias "clutter-gst_3" { };

clutter-gtk_1-8 = callPackage ../all-pkgs/c/clutter-gtk {
  channel = "1.8";
};
clutter-gtk = callPackageAlias "clutter-gtk_1-8" { };

cmake = callPackage ../all-pkgs/c/cmake { };

cogl = callPackage ../all-pkgs/c/cogl { };

colord = callPackage ../all-pkgs/c/colord { };

colord-gtk = callPackage ../all-pkgs/c/colord-gtk { };

conntrack-tools = callPackage ../all-pkgs/c/conntrack-tools { };

consul = pkgs.goPackages.consul.bin // { outputs = [ "bin" ]; };

consul-template = pkgs.goPackages.consul-template.bin // { outputs = [ "bin" ]; };

consul-ui = callPackage ../all-pkgs/c/consul-ui { };

coreutils = callPackage ../all-pkgs/c/coreutils { };

cpio = callPackage ../all-pkgs/c/cpio { };

cracklib = callPackage ../all-pkgs/c/cracklib { };

cryptodevHeaders = callPackage ../all-pkgs/c/cryptodev {
  onlyHeaders = true;
  kernel = null;
};

cryptopp = callPackage ../all-pkgs/c/crypto++ { };

cryptsetup = callPackage ../all-pkgs/c/cryptsetup { };

cscope = callPackage ../all-pkgs/c/cscope { };

cuetools = callPackage ../all-pkgs/c/cuetools { };

cups = callPackage ../all-pkgs/c/cups { };

curl = callPackage ../all-pkgs/c/curl {
  suffix = "";
};
curl_full = callPackageAlias "curl" {
  suffix = "full";
};

cyrus-sasl = callPackage ../all-pkgs/c/cyrus-sasl { };

dash = callPackage ../all-pkgs/d/dash { };

db = callPackage ../all-pkgs/d/db { };
db_5 = callPackageAlias "db" {
  channel = "5";
};
db_6 = callPackageAlias "db" {
  channel = "6";
};

dbus = callPackage ../all-pkgs/d/dbus { };

dbus-glib = callPackage ../all-pkgs/d/dbus-glib { };

dconf = callPackage ../all-pkgs/d/dconf { };

dconf-editor = callPackage ../all-pkgs/d/dconf-editor { };

ddrescue = callPackage ../all-pkgs/d/ddrescue { };

dejagnu = callPackage ../all-pkgs/d/dejagnu { };

dejavu-fonts = callPackage ../all-pkgs/d/dejavu-fonts { };

dialog = callPackage ../all-pkgs/d/dialog { };

ding-libs = callPackage ../all-pkgs/d/ding-libs { };

dmenu = callPackage ../all-pkgs/d/dmenu { };

devil_nox = callPackageAlias "devil" {
  xorg = null;
  mesa = null;
};
devil = callPackage ../all-pkgs/d/devil { };

dhcp = callPackage ../all-pkgs/d/dhcp { };

dhcpcd = callPackage ../all-pkgs/d/dhcpcd { };

diffutils = callPackage ../all-pkgs/d/diffutils { };

dmidecode = callPackage ../all-pkgs/d/dmidecode { };

dnscrypt-proxy = callPackage ../all-pkgs/d/dnscrypt-proxy { };

dnscrypt-wrapper = callPackage ../all-pkgs/d/dnscrypt-wrapper { };

dnsmasq = callPackage ../all-pkgs/d/dnsmasq { };

docbook-xsl = callPackage ../all-pkgs/d/docbook-xsl { };

docbook-xsl-ns = callPackageAlias "docbook-xsl" {
  type = "ns";
};

dosfstools = callPackage ../all-pkgs/d/dosfstools { };

dos2unix = callPackage ../all-pkgs/d/dos2unix { };

dotconf = callPackage ../all-pkgs/d/dotconf { };

double-conversion = callPackage ../all-pkgs/d/double-conversion { };

dpdk = callPackage ../all-pkgs/d/dpdk { };

#dropbox = callPackage ../all-pkgs/d/dropbox { };

dtc = callPackage ../all-pkgs/d/dtc { };

duplicity = pkgs.pythonPackages.duplicity;

e2fsprogs = callPackage ../all-pkgs/e/e2fsprogs { };

edac-utils = callPackage ../all-pkgs/e/edac-utils { };

efibootmgr = callPackage ../all-pkgs/e/efibootmgr { };

efivar = callPackage ../all-pkgs/e/efivar { };

eigen = callPackage ../all-pkgs/e/eigen { };

elfutils = callPackage ../all-pkgs/e/elfutils { };

emacs = callPackage ../all-pkgs/e/emacs { };

enca = callPackage ../all-pkgs/e/enca { };

enchant = callPackage ../all-pkgs/e/enchant { };

eog = callPackage ../all-pkgs/e/eog { };

erlang = callPackage ../all-pkgs/e/erlang { };

ethtool = callPackage ../all-pkgs/e/ethtool { };

evince = callPackage ../all-pkgs/e/evince { };

#evolution = callPackage ../all-pkgs/e/evolution { };

evolution-data-server = callPackage ../all-pkgs/e/evolution-data-server { };

exempi = callPackage ../all-pkgs/e/exempi { };

exiv2 = callPackage ../all-pkgs/e/exiv2 { };

expat = callPackage ../all-pkgs/e/expat { };

expect = callPackage ../all-pkgs/e/expect { };

f2fs-tools = callPackage ../all-pkgs/f/f2fs-tools { };

faac = callPackage ../all-pkgs/f/faac { };

fcgi = callPackage ../all-pkgs/f/fcgi { };

feh = callPackage ../all-pkgs/f/feh { };

ffmpeg_generic = overrides: callPackage ../all-pkgs/f/ffmpeg ({
  # The following are disabled by default
  celt = null;
  dcadec = null;
  faac = null;
  fdk_aac = null;
  frei0r = null;
  fribidi = null;
  game-music-emu = null;
  gmp = null;
  gsm = null;
  #iblc = null;
  jni = null;
  kvazaar = null;
  ladspaH = null;
  #libavc1394 = null;
  libbs2b = null;
  libcaca = null;
  libdc1394 = null;
  #libiec61883 = null;
  libraw1394 = null;
  libmodplug = null;
  #libnut = null;
  #libnpp = null;
  libssh = null;
  libwebp = null; # ???
  libzimg = null;
  mfx-dispatcher = null;
  mmal = null;
  netcdf = null;
  openal = null;
  #opencl = null;
  #opencore-amr = null;
  opencv = null;
  openjpeg_1 = null;
  samba_client = null;
  #schannel = null;
  schroedinger = null;
  #shine = null;
  snappy = null;
  rtmpdump = null;
  rubberband = null;
  tesseract = null;
  #twolame = null;
  #utvideo = null;
  vid-stab = null;
  vo-amrwbenc = null;
  wavpack = null;
  xavs = null;
  xvidcore = null;
  zeromq4 = null;
  #zvbi = null;
} // overrides);
ffmpeg_2-8 = pkgs.ffmpeg_generic {
  channel = "2.8";
};
ffmpeg_2 = callPackageAlias "ffmpeg_2-8" { };
ffmpeg_3-1 = pkgs.ffmpeg_generic {
  channel = "3.1";
};
ffmpeg_3 = callPackageAlias "ffmpeg_3-1" { };
ffmpeg_head = pkgs.ffmpeg_generic {
  channel = "9.9";
};
ffmpeg = callPackageAlias "ffmpeg_3" { };

fftw_double = callPackage ../all-pkgs/f/fftw {
  precision = "double";
};
fftw_long-double = callPackage ../all-pkgs/f/fftw {
  precision = "long-double";
};
fftw_quad = callPackage ../all-pkgs/f/fftw {
  precision = "quad-precision";
};
fftw_single = callPackage ../all-pkgs/f/fftw {
  precision = "single";
};

file = callPackage ../all-pkgs/f/file { };

file-roller = callPackage ../all-pkgs/f/file-roller { };

filezilla = callPackage ../all-pkgs/f/filezilla { };

findutils = callPackage ../all-pkgs/f/findutils { };

firefox = pkgs.firefox_wrapper pkgs.firefox-unwrapped { };
firefox-esr = pkgs.firefox_wrapper pkgs.firefox-esr-unwrapped { };
firefox-unwrapped = callPackage ../all-pkgs/f/firefox { };
firefox-esr-unwrapped = callPackage ../all-pkgs/f/firefox {
  channel = "esr";
};
firefox_wrapper = callPackage ../all-pkgs/f/firefox/wrapper.nix { };

#firefox-bin = callPackage ../applications/networking/browsers/firefox-bin { };

fish = callPackage ../all-pkgs/f/fish { };

flac = callPackage ../all-pkgs/f/flac { };

flex = callPackage ../all-pkgs/f/flex { };

fox = callPackage ../all-pkgs/f/fox { };

freeglut = callPackage ../all-pkgs/f/freeglut { };

freeipmi = callPackage ../all-pkgs/f/freeipmi { };

freetype = callPackage ../all-pkgs/f/freetype { };

freetype2-infinality-ultimate =
  callPackage ../all-pkgs/f/freetype2-infinality-ultimate { };

fstrm = callPackage ../all-pkgs/f/fstrm { };

fuse = callPackage ../all-pkgs/f/fuse { };

game-music-emu = callPackage ../all-pkgs/g/game-music-emu { };

gawk = callPackage ../all-pkgs/g/gawk { };

gcab = callPackage ../all-pkgs/g/gcab { };

gconf = callPackage ../all-pkgs/g/gconf { };

gcr = callPackage ../all-pkgs/g/gcr { };

gdbm = callPackage ../all-pkgs/g/gdbm { };

gdk-pixbuf_wrapped = callPackage ../all-pkgs/g/gdk-pixbuf { };
gdk-pixbuf_unwrapped = callPackage ../all-pkgs/g/gdk-pixbuf/unwrapped.nix { };
gdk-pixbuf = callPackageAlias "gdk-pixbuf_wrapped" { };

gdm = callPackage ../all-pkgs/g/gdm { };

geoclue = callPackage ../all-pkgs/g/geoclue { };

gegl = callPackage ../all-pkgs/g/gegl { };

geocode-glib = callPackage ../all-pkgs/g/geocode-glib { };

geoip = callPackage ../all-pkgs/g/geoip { };

getopt = callPackage ../all-pkgs/g/getopt { };

gettext = callPackage ../all-pkgs/g/gettext { };

gexiv2 = callPackage ../all-pkgs/g/gexiv2 { };

gimp = callPackage ../all-pkgs/g/gimp { };

git = callPackage ../all-pkgs/g/git { };

gjs = callPackage ../all-pkgs/g/gjs { };

gksu = callPackage ../all-pkgs/g/gksu { };

glfw = callPackage ../all-pkgs/g/glfw { };

glib = callPackage ../all-pkgs/g/glib {
  channel = "2.48";
};

glib-networking = callPackage ../all-pkgs/g/glib-networking { };

glibmm = callPackage ../all-pkgs/g/glibmm { };

glusterfs = callPackage ../all-pkgs/g/glusterfs { };

gmp = callPackage ../all-pkgs/g/gmp { };

gnome-backgrounds = callPackage ../all-pkgs/g/gnome-backgrounds { };

gnome-bluetooth = callPackage ../all-pkgs/g/gnome-bluetooth { };

gnome-calculator = callPackage ../all-pkgs/g/gnome-calculator { };

gnome-clocks = callPackage ../all-pkgs/g/gnome-clocks { };

gnome-common = callPackage ../all-pkgs/g/gnome-common { };

gnome-control-center = callPackage ../all-pkgs/g/gnome-control-center { };

gnome-desktop = callPackage ../all-pkgs/g/gnome-desktop { };

gnome-documents_3-20 = callPackage ../all-pkgs/g/gnome-documents {
  channel = "3.20";
};
gnome-documents = callPackageAlias "gnome-documents_3-20" { };

gnome-keyring = callPackage ../all-pkgs/g/gnome-keyring { };

gnome-menus = callPackage ../all-pkgs/g/gnome-menus { };

gnome-mpv = callPackage ../all-pkgs/g/gnome-mpv { };

gnome-online-accounts = callPackage ../all-pkgs/g/gnome-online-accounts { };

gnome-online-miners = callPackage ../all-pkgs/g/gnome-online-miners { };

gnome-screenshot = callPackage ../all-pkgs/g/gnome-screenshot { };

gnome-session = callPackage ../all-pkgs/g/gnome-session { };

gnome-settings-daemon = callPackage ../all-pkgs/g/gnome-settings-daemon { };

gnome-shell = callPackage ../all-pkgs/g/gnome-shell { };

gnome-shell-extensions = callPackage ../all-pkgs/g/gnome-shell-extensions { };

gnome-terminal = callPackage ../all-pkgs/g/gnome-terminal { };

gnome-themes-standard = callPackage ../all-pkgs/g/gnome-themes-standard { };

gnome-user-share = callPackage ../all-pkgs/g/gnome-user-share { };

gnome-wrapper = makeSetupHook {
  deps = [ makeWrapper ];
} ../build-support/setup-hooks/gnome-wrapper.sh;

gnonlin = callPackage ../all-pkgs/g/gnonlin { };

gnu-efi = callPackage ../all-pkgs/g/gnu-efi { };

gnugrep = callPackage ../all-pkgs/g/gnugrep { };

gnum4 = callPackage ../all-pkgs/g/gnum4 { };

gnumake = callPackage ../all-pkgs/g/gnumake { };

gnupatch = callPackage ../all-pkgs/g/gnupatch { };

gnupg_2_0 = callPackageAlias "gnupg" {
  channel = "2.0";
};
gnupg_2_1 = callPackageAlias "gnupg" {
  channel = "2.1";
};
gnupg = callPackage ../all-pkgs/g/gnupg { };

gnused = callPackage ../all-pkgs/g/gnused { };

gnutar = callPackage ../all-pkgs/g/gnutar { };

gnutls = callPackage ../all-pkgs/g/gnutls { };

go = callPackage ../all-pkgs/g/go { };

go_1_6 = callPackageAlias "go" {
  channel = "1.6";
};

go_1_7 = callPackageAlias "go" {
  channel = "1.7";
};

go16Packages = callPackage ./go-packages.nix {
  go = callPackageAlias "go_1_6" { };
  buildGoPackage = callPackage ../all-pkgs/b/build-go-package {
    go = callPackageAlias "go_1_6" { };
    govers = (callPackageAlias "go16Packages" { }).govers.bin;
  };
  overrides = (config.goPackageOverrides or (p: { })) pkgs;
};

go17Packages = callPackage ./go-packages.nix {
  go = callPackageAlias "go_1_7" { };
  buildGoPackage = callPackage ../all-pkgs/b/build-go-package {
    go = callPackageAlias "go_1_7" { };
    govers = (callPackageAlias "go17Packages" { }).govers.bin;
  };
  overrides = (config.goPackageOverrides or (p: { })) pkgs;
};

goPackages = callPackageAlias "go17Packages" { };

gobject-introspection = callPackage ../all-pkgs/g/gobject-introspection { };

google-gflags = callPackage ../all-pkgs/g/google-gflags { };

gperf = callPackage ../all-pkgs/g/gperf { };

gperftools = callPackage ../all-pkgs/g/gperftools { };

gpm = callPackage ../all-pkgs/g/gpm-ncurses { };

gpsd = callPackage ../all-pkgs/g/gpsd { };

gptfdisk = callPackage ../all-pkgs/g/gptfdisk { };

grafana = pkgs.goPackages.grafana.bin // { outputs = [ "bin" ]; };

granite = callPackage ../all-pkgs/g/granite { };

graphite2 = callPackage ../all-pkgs/g/graphite2 { };

graphviz = callPackage ../all-pkgs/g/graphviz { };

grilo = callPackage ../all-pkgs/g/grilo { };

grilo-plugins = callPackage ../all-pkgs/g/grilo-plugins { };

groff = callPackage ../all-pkgs/g/groff { };

gsettings-desktop-schemas = callPackage ../all-pkgs/g/gsettings-desktop-schemas { };

gsm = callPackage ../all-pkgs/g/gsm { };

gsound = callPackage ../all-pkgs/g/gsound { };

gssdp = callPackage ../all-pkgs/g/gssdp { };

gst-libav = callPackage ../all-pkgs/g/gst-libav { };

gst-plugins-bad = callPackage ../all-pkgs/g/gst-plugins-bad { };

gst-plugins-base = callPackage ../all-pkgs/g/gst-plugins-base { };

gst-plugins-good = callPackage ../all-pkgs/g/gst-plugins-good { };

gst-plugins-ugly = callPackage ../all-pkgs/g/gst-plugins-ugly { };

gst-validate = callPackage ../all-pkgs/g/gst-validate { };

gstreamer = callPackage ../all-pkgs/g/gstreamer { };

gstreamer-editing-services = callPackage ../all-pkgs/g/gstreamer-editing-services { };

gstreamer-vaapi = callPackage ../all-pkgs/g/gstreamer-vaapi { };

googletest = callPackage ../all-pkgs/g/googletest { };

gtk_2 = callPackage ../all-pkgs/g/gtk/2.x.nix { };
gtk2 = callPackageAlias "gtk_2" { };
gtk_3 = callPackage ../all-pkgs/g/gtk/3.x.nix { };
gtk3 = callPackageAlias "gtk_3" { };

gtk-doc = callPackage ../all-pkgs/g/gtk-doc { };

gtkhtml = callPackage ../all-pkgs/g/gtkhtml { };

gtkimageview = callPackage ../all-pkgs/g/gtkimageview { };

gtkmm_2 = callPackage ../all-pkgs/g/gtkmm/2.x.nix { };
gtkmm_3 = callPackage ../all-pkgs/g/gtkmm/3.x.nix { };

gtksourceview = callPackage ../all-pkgs/g/gtksourceview { };

gtkspell_2 = callPackage ../all-pkgs/g/gtkspell/2.x.nix { };
gtkspell_3 = callPackage ../all-pkgs/g/gtkspell/3.x.nix { };
gtkspell = callPackageAlias "gtkspell_3" { };

guile = callPackage ../all-pkgs/g/guile { };

guitarix = callPackage ../all-pkgs/g/guitarix {
  fftw = pkgs.fftw_single;
};

gupnp = callPackage ../all-pkgs/g/gupnp { };

gupnp-av = callPackage ../all-pkgs/g/gupnp-av { };

gupnp-igd = callPackage ../all-pkgs/g/gupnp-igd { };

gvfs = callPackage ../all-pkgs/g/gvfs { };

gx = pkgs.goPackages.gx.bin // { outputs = [ "bin" ]; };

gzip = callPackage ../all-pkgs/g/gzip { };

hadoop = callPackage ../all-pkgs/h/hadoop { };

harfbuzz = callPackage ../all-pkgs/h/harfbuzz { };

hdparm = callPackage ../all-pkgs/h/hdparm { };

help2man = callPackage ../all-pkgs/h/help2man { };

hexchat = callPackage ../all-pkgs/h/hexchat { };

hicolor-icon-theme = callPackage ../all-pkgs/h/hicolor-icon-theme { };

hidapi = callPackage ../all-pkgs/h/hidapi { };

highlight = callPackage ../all-pkgs/h/highlight { };

hiredis = callPackage ../all-pkgs/h/hiredis { };

htop = callPackage ../all-pkgs/h/htop { };

http-parser = callPackage ../all-pkgs/h/http-parser { };

httping = callPackage ../all-pkgs/h/httping { };

hunspell = callPackage ../all-pkgs/h/hunspell { };

hwdata = callPackage ../all-pkgs/h/hwdata { };

iana-etc = callPackage ../all-pkgs/i/iana-etc { };

iasl = callPackage ../all-pkgs/i/iasl { };

ibus = callPackage ../all-pkgs/i/ibus { };

ice = callPackage ../all-pkgs/i/ice { };

icu = callPackage ../all-pkgs/i/icu { };

id3lib = callPackage ../all-pkgs/i/id3lib { };

id3v2 = callPackage ../all-pkgs/i/id3v2 { };

imagemagick = callPackage ../all-pkgs/i/imagemagick { };

iniparser = callPackage ../all-pkgs/i/iniparser { };

inkscape = callPackage ../all-pkgs/i/inkscape { };

intel-microcode = callPackage ../all-pkgs/i/intel-microcode { };

intltool = callPackage ../all-pkgs/i/intltool { };

iotop = pkgs.python3Packages.iotop;

iperf = callPackage ../all-pkgs/i/iperf { };
iperf_2 = callPackageAlias "iperf" {
  channel = "2";
};
iperf_3 = callPackageAlias "iperf" {
  channel = "3";
};

ipfs = pkgs.goPackages.ipfs.bin // { outputs = [ "bin" ]; };

ipfs-hasher = callPackage ../all-pkgs/i/ipfs-hasher { };

ipmitool = callPackage ../all-pkgs/i/ipmitool { };

iproute = callPackage ../all-pkgs/i/iproute { };

ipset = callPackage ../all-pkgs/i/ipset { };

iptables = callPackage ../all-pkgs/i/iptables { };

iputils = callPackage ../all-pkgs/i/iputils { };

isl = callPackage ../all-pkgs/i/isl { };
isl_0_14 = callPackage ../all-pkgs/i/isl { channel = "0.14"; };

iso-codes = callPackage ../all-pkgs/i/iso-codes { };

itstool = callPackage ../all-pkgs/i/itstool { };

iw = callPackage ../all-pkgs/i/iw { };

jam = callPackage ../all-pkgs/j/jam { };

jansson = callPackage ../all-pkgs/j/jansson { };

jemalloc = callPackage ../all-pkgs/j/jemalloc { };

jq = callPackage ../all-pkgs/j/jq { };

jshon = callPackage ../all-pkgs/j/jshon { };

json-c = callPackage ../all-pkgs/j/json-c { };

json-glib = callPackage ../all-pkgs/j/json-glib { };

jsoncpp = callPackage ../all-pkgs/j/jsoncpp { };

judy = callPackage ../all-pkgs/j/judy { };

kbd = callPackage ../all-pkgs/k/kbd { };

kea = callPackage ../all-pkgs/k/kea { };

keepalived = callPackage ../all-pkgs/k/keepalived { };

keepassx = callPackage ../all-pkgs/k/keepassx { };

kerberos = callPackageAlias "krb5_lib" { };

kexec-tools = callPackage ../all-pkgs/k/kexec-tools { };

keyutils = callPackage ../all-pkgs/k/keyutils { };

kid3 = callPackage ../all-pkgs/k/kid3 { };

kmod = callPackage ../all-pkgs/k/kmod { };

kmscon = callPackage ../all-pkgs/k/kmscon { };

knot = callPackage ../all-pkgs/k/knot { };

krb5_full = callPackage ../all-pkgs/k/krb5 { };
krb5_lib = callPackageAlias "krb5_full" {
  type = "lib";
};

#kubernetes = callPackage ../all-pkgs/k/kubernetes { };

kyotocabinet = callPackage ../all-pkgs/k/kyotocabinet { };

lame = callPackage ../all-pkgs/l/lame {
  libsndfile = null;
};

ldb = callPackage ../all-pkgs/l/ldb { };

lego = pkgs.goPackages.lego.bin // { outputs = [ "bin" ]; };

lensfun = callPackage ../all-pkgs/l/lensfun { };

leptonica = callPackage ../all-pkgs/l/leptonica { };

letskencrypt = callPackage ../all-pkgs/l/letskencrypt { };

leveldb = callPackage ../all-pkgs/l/leveldb { };

lftp = callPackage ../all-pkgs/l/lftp { };

lib-bash = callPackage ../all-pkgs/l/lib-bash { };

libaccounts-glib = callPackage ../all-pkgs/l/libaccounts-glib { };

libaio = callPackage ../all-pkgs/l/libaio { };

libarchive = callPackage ../all-pkgs/l/libarchive { };

libasr = callPackage ../all-pkgs/l/libasr { };

libass = callPackage ../all-pkgs/l/libass { };

libassuan = callPackage ../all-pkgs/l/libassuan { };

libatasmart = callPackage ../all-pkgs/l/libatasmart { };

libatomic_ops = callPackage ../all-pkgs/l/libatomic_ops { };

libavc1394 = callPackage ../all-pkgs/l/libavc1394 { };

libbluray = callPackage ../all-pkgs/l/libbluray { };

libbsd = callPackage ../all-pkgs/l/libbsd { };

libburn = callPackage ../all-pkgs/l/libburn { };

libcacard = callPackage ../all-pkgs/l/libcacard { };

libcanberra = callPackage ../all-pkgs/l/libcanberra { };

libcap-ng = callPackage ../all-pkgs/l/libcap-ng { };

libclc = callPackage ../all-pkgs/l/libclc { };

libcroco = callPackage ../all-pkgs/l/libcroco { };

libcue = callPackage ../all-pkgs/l/libcue { };

libdc1394 = callPackage ../all-pkgs/l/libdc1394 { };

libdrm = callPackage ../all-pkgs/l/libdrm { };

libebml = callPackage ../all-pkgs/l/libebml { };

libedit = callPackage ../all-pkgs/l/libedit { };

libelf = callPackage ../all-pkgs/l/libelf { };

libepoxy = callPackage ../all-pkgs/l/libepoxy { };

liberation-fonts = callPackage ../all-pkgs/l/liberation-fonts { };

libev = callPackage ../all-pkgs/l/libev { };

libevdev = callPackage ../all-pkgs/l/libevdev { };

libevent = callPackage ../all-pkgs/l/libevent { };

libfaketime = callPackage ../all-pkgs/l/libfaketime { };

libffi = callPackage ../all-pkgs/l/libffi { };

libfilezilla = callPackage ../all-pkgs/l/libfilezilla { };

libfpx = callPackage ../all-pkgs/l/libfpx { };

libgcrypt = callPackage ../all-pkgs/l/libgcrypt { };

libgd = callPackage ../all-pkgs/l/libgd { };

libgda = callPackage ../all-pkgs/l/libgda { };

libgdata = callPackage ../all-pkgs/l/libgdata { };

libgee = callPackage ../all-pkgs/l/libgee { };

libgfbgraph = callPackage ../all-pkgs/l/libgfbgraph { };

libgksu = callPackage ../all-pkgs/l/libgksu { };

libglade = callPackage ../all-pkgs/l/libglade { };

libglvnd = callPackage ../all-pkgs/l/libglvnd { };

libgnome-keyring = callPackage ../all-pkgs/l/libgnome-keyring { };

libgnomekbd = callPackage ../all-pkgs/l/libgnomekbd { };

libgpg-error = callPackage ../all-pkgs/l/libgpg-error { };

libgphoto2 = callPackage ../all-pkgs/l/libgphoto2 { };

libgpod = callPackage ../all-pkgs/l/libgpod {
  inherit (pkgs.pythonPackages) mutagen;
};

libgsf = callPackage ../all-pkgs/l/libgsf { };

libgudev = callPackage ../all-pkgs/l/libgudev { };

libgusb = callPackage ../all-pkgs/l/libgusb { };

libgweather = callPackage ../all-pkgs/l/libgweather { };

libgxps = callPackage ../all-pkgs/l/libgxps { };

libibverbs = callPackage ../all-pkgs/l/libibverbs { };

libical = callPackage ../all-pkgs/l/libical { };

libidl = callPackage ../all-pkgs/l/libidl { };

libidn = callPackage ../all-pkgs/l/libidn { };

libiodbc = callPackage ../all-pkgs/l/libiodbc {
  gtk_2 = null;
};

libinput = callPackage ../all-pkgs/l/libinput { };

libisoburn = callPackage ../all-pkgs/l/libisoburn { };

libisofs = callPackage ../all-pkgs/l/libisofs { };

libjpeg_original = callPackage ../all-pkgs/l/libjpeg { };
libjpeg-turbo_1-4 = callPackage ../all-pkgs/l/libjpeg-turbo {
  channel = "1.4";
};
libjpeg-turbo_1-5 = callPackage ../all-pkgs/l/libjpeg-turbo {
  channel = "1.5";
};
libjpeg-turbo = callPackageAlias "libjpeg-turbo_1-5" { };
libjpeg = callPackageAlias "libjpeg-turbo" { };

libkate = callPackage ../all-pkgs/l/libkate { };

libksba = callPackage ../all-pkgs/l/libksba { };

liblogging = callPackage ../all-pkgs/l/liblogging { };

libmatroska = callPackage ../all-pkgs/l/libmatroska { };

libmbim = callPackage ../all-pkgs/l/libmbim { };

libmcrypt = callPackage ../all-pkgs/l/libmcrypt { };

libmediaart = callPackage ../all-pkgs/l/libmediaart {
  qt5 = null;
};

libmhash = callPackage ../all-pkgs/l/libmhash { };

libmicrohttpd = callPackage ../all-pkgs/l/libmicrohttpd { };

libmnl = callPackage ../all-pkgs/l/libmnl { };

libmodplug = callPackage ../all-pkgs/l/libmodplug { };

libmpc = callPackage ../all-pkgs/l/libmpc { };

libmpdclient = callPackage ../all-pkgs/l/libmpdclient { };

libmpeg2 = callPackage ../all-pkgs/l/libmpeg2 {
  libSDL = null;
  xorg = null;
};

libmsgpack = callPackage ../all-pkgs/l/libmsgpack { };

libmtp = callPackage ../all-pkgs/l/libmtp { };

libmusicbrainz = callPackage ../all-pkgs/l/libmusicbrainz { };

libmypaint = callPackage ../all-pkgs/l/libmypaint { };

libnetfilter_acct = callPackage ../all-pkgs/l/libnetfilter_acct { };

libnetfilter_conntrack = callPackage ../all-pkgs/l/libnetfilter_conntrack { };

libnetfilter_cthelper = callPackage ../all-pkgs/l/libnetfilter_cthelper { };

libnetfilter_cttimeout = callPackage ../all-pkgs/l/libnetfilter_cttimeout { };

libnetfilter_queue = callPackage ../all-pkgs/l/libnetfilter_queue { };

libnfnetlink = callPackage ../all-pkgs/l/libnfnetlink { };

libnfsidmap = callPackage ../all-pkgs/l/libnfsidmap { };

libnftnl = callPackage ../all-pkgs/l/libnftnl { };

libnih = callPackage ../all-pkgs/l/libnih { };

libnl = callPackage ../all-pkgs/l/libnl { };

libogg = callPackage ../all-pkgs/l/libogg { };

libomxil-bellagio = callPackage ../all-pkgs/l/libomxil-bellagio { };

libosinfo = callPackage ../all-pkgs/l/libosinfo { };

libossp-uuid = callPackage ../all-pkgs/l/libossp-uuid { };

libpcap = callPackage ../all-pkgs/l/libpcap { };

libpeas = callPackage ../all-pkgs/l/libpeas { };

libpipeline = callPackage ../all-pkgs/l/libpipeline { };

libpng = callPackage ../all-pkgs/l/libpng { };

libproxy = callPackage ../all-pkgs/l/libproxy { };

libqmi = callPackage ../all-pkgs/l/libqmi { };

libraw = callPackage ../all-pkgs/l/libraw { };

libraw1394 = callPackage ../all-pkgs/l/libraw1394 { };

librelp = callPackage ../all-pkgs/l/librelp { };

libressl = callPackage ../all-pkgs/l/libressl { };

librdmacm = callPackage ../all-pkgs/l/librdmacm { };

librsvg = callPackage ../all-pkgs/l/librsvg { };

librsync = callPackage ../all-pkgs/l/librsync { };

libs3 = callPackage ../all-pkgs/l/libs3 { };

libsamplerate = callPackage ../all-pkgs/l/libsamplerate { };

libscrypt = callPackage ../all-pkgs/l/libscrypt { };

libseccomp = callPackage ../all-pkgs/l/libseccomp { };

libsecret = callPackage ../all-pkgs/l/libsecret { };

libselinux = callPackage ../all-pkgs/l/libselinux { };

libsepol = callPackage ../all-pkgs/l/libsepol { };

libshout = callPackage ../all-pkgs/l/libshout { };

libsigcxx = callPackage ../all-pkgs/l/libsigcxx { };

libsigsegv = callPackage ../all-pkgs/l/libsigsegv { };

libsmbios = callPackage ../all-pkgs/l/libsmbios { };

libsndfile = callPackage ../all-pkgs/l/libsndfile { };

libsodium = callPackage ../all-pkgs/l/libsodium { };

libsoup = callPackage ../all-pkgs/l/libsoup { };

libspectre = callPackage ../all-pkgs/l/libspectre { };

libssh = callPackage ../all-pkgs/l/libssh { };

libssh2 = callPackage ../all-pkgs/l/libssh2 { };

libtasn1 = callPackage ../all-pkgs/l/libtasn1 { };

libtheora = callPackage ../all-pkgs/l/libtheora { };

libtirpc = callPackage ../all-pkgs/l/libtirpc { };

libtool = callPackage ../all-pkgs/l/libtool { };

libtorrent = callPackage ../all-pkgs/l/libtorrent { };

libtorrent-rasterbar_1-0 = callPackage ../all-pkgs/l/libtorrent-rasterbar {
  channel = "1.0";
};
libtorrent-rasterbar_1-1 = callPackage ../all-pkgs/l/libtorrent-rasterbar {
  channel = "1.1";
};
libtorrent-rasterbar = callPackageAlias "libtorrent-rasterbar_1-1" { };

libtsm = callPackage ../all-pkgs/l/libtsm { };

libu2f-host = callPackage ../all-pkgs/l/libu2f-host { };

libunique_1 = callPackage ../all-pkgs/l/libunique/1.x.nix { };
libunique_3 = callPackage ../all-pkgs/l/libunique/3.x.nix { };
libunique = callPackageAlias "libunique_3" { };

libunwind = callPackage ../all-pkgs/l/libunwind { };

liburcu = callPackage ../all-pkgs/l/liburcu { };

libusb_0 = callPackageAlias "libusb-compat" { };
libusb_1 = callPackage ../all-pkgs/l/libusb { };
libusb = callPackageAlias "libusb_1" { };

libusb-compat = callPackage ../all-pkgs/l/libusb-compat { };

libusbmuxd = callPackage ../all-pkgs/l/libusbmuxd { };

libutempter = callPackage ../all-pkgs/l/libutempter { };

libuv = callPackage ../all-pkgs/l/libuv { };

libva = callPackage ../all-pkgs/l/libva { };

libva-vdpau-driver = callPackage ../all-pkgs/l/libva-vdpau-driver { };

libvdpau = callPackage ../all-pkgs/l/libvdpau { };

libvdpau-va-gl = callPackage ../all-pkgs/l/libvdpau-va-gl { };

libverto = callPackage ../all-pkgs/l/libverto { };

libvorbis = callPackage ../all-pkgs/l/libvorbis { };

libvpx = callPackage ../all-pkgs/l/libvpx { };
#libvpx_HEAD = callPackage ../development/libraries/libvpx/git.nix { };

libwacom = callPackage ../all-pkgs/l/libwacom { };

libwebp = callPackage ../all-pkgs/l/libwebp { };

libwps = callPackage ../all-pkgs/l/libwps { };

libxkbcommon = callPackage ../all-pkgs/l/libxkbcommon { };

libxklavier = callPackage ../all-pkgs/l/libxklavier { };

libxml2 = callPackage ../all-pkgs/l/libxml2 { };

libxslt = callPackage ../all-pkgs/l/libxslt { };

libyaml = callPackage ../all-pkgs/l/libyaml { };

libzapojit = callPackage ../all-pkgs/l/libzapojit { };

libzip = callPackage ../all-pkgs/l/libzip { };

lightdm = callPackage ../all-pkgs/l/lightdm { };

lightdm-gtk-greeter = callPackage ../all-pkgs/l/lightdm-gtk-greeter { };

lilv = callPackage ../all-pkgs/l/lilv { };

linux-headers = callPackage ../all-pkgs/l/linux-headers { };
linux-headers_4_6 = callPackage ../all-pkgs/l/linux-headers {
  channel = "4.6";
};

lirc = callPackage ../all-pkgs/l/lirc { };

live555 = callPackage ../all-pkgs/l/live555 { };

llvm = callPackage ../all-pkgs/l/llvm { };
llvm_3-8 = callPackageAlias "llvm" {
  channel = "3.8";
};
llvm_3-9 = callPackageAlias "llvm" {
  channel = "3.9";
};

lm-sensors = callPackage ../all-pkgs/l/lm-sensors { };

lmdb = callPackage ../all-pkgs/l/lmdb { };

lrdf = callPackage ../all-pkgs/l/lrdf { };

lsof = callPackage ../all-pkgs/l/lsof { };

luajit = callPackage ../all-pkgs/l/luajit { };

lv2 = callPackage ../all-pkgs/l/lv2 { };

lvm2 = callPackage ../all-pkgs/l/lvm2 { };

lxc = callPackage ../all-pkgs/l/lxc { };

lxd = pkgs.goPackages.lxd.bin // { outputs = [ "bin" ]; };

lz4 = callPackage ../all-pkgs/l/lz4 { };

lzip = callPackage ../all-pkgs/l/lzip { };

lzo = callPackage ../all-pkgs/l/lzo { };

m4 = callPackageAlias "gnum4" { };

mac = callPackage ../all-pkgs/m/mac { };

man-db = callPackage ../all-pkgs/m/man-db { };

man-pages = callPackage ../all-pkgs/m/man-pages { };

mediainfo = callPackage ../all-pkgs/m/mediainfo { };

mercurial = callPackage ../all-pkgs/m/mercurial { };

mesa_glu =  callPackage ../all-pkgs/m/mesa-glu { };
mesa_noglu = callPackage ../all-pkgs/m/mesa {
  libglvnd = null;
  # makes it slower, but during runtime we link against just
  # mesa_drivers through mesa_noglu.driverSearchPath, which is overriden
  # according to config.grsecurity
  grsecEnabled = config.grsecurity or false;
};
mesa_drivers = pkgs.mesa_noglu.drivers;
mesa = pkgs.buildEnv {
  name = "mesa-${pkgs.mesa_noglu.version}";
  paths = with pkgs; [ mesa_noglu mesa_glu ];
  passthru = pkgs.mesa_glu.passthru // pkgs.mesa_noglu.passthru;
};

#mesos = callPackage ../all-pkgs/m/mesos {
#  inherit (pythonPackages) python boto setuptools wrapPython;
#  pythonProtobuf = pythonPackages.protobuf2_5;
#  perf = linuxPackages.perf;
#};

mfx-dispatcher = callPackage ../all-pkgs/m/mfx-dispatcher { };

mg = callPackage ../all-pkgs/m/mg { };

mime-types = callPackage ../all-pkgs/m/mime-types { };

minipro = callPackage ../all-pkgs/m/minipro { };

minisign = callPackage ../all-pkgs/m/minisign { };

mixxx = callPackage ../all-pkgs/m/mixxx { };

mkvtoolnix = callPackage ../all-pkgs/m/mkvtoolnix { };

modemmanager = callPackage ../all-pkgs/m/modemmanager { };

mongodb = callPackage ../all-pkgs/m/mongodb { };

mongodb-tools = pkgs.goPackages.mongo-tools.bin // { outputs = [ "bin" ]; };

mosh = callPackage ../all-pkgs/m/mosh { };

motif = callPackage ../all-pkgs/m/motif { };

mp3val = callPackage ../all-pkgs/m/mp3val { };

mp4v2 = callPackage ../all-pkgs/m/mp4v2 { };

mpd = callPackage ../all-pkgs/m/mpd { };

mpdris2 = callPackage ../all-pkgs/m/mpdris2 { };

mpfr = callPackage ../all-pkgs/m/mpfr { };

mpv = callPackage ../all-pkgs/m/mpv { };

ms-sys = callPackage ../all-pkgs/m/ms-sys { };

mtdev = callPackage ../all-pkgs/m/mtdev { };

mtools = callPackage ../all-pkgs/m/mtools { };

mtr = callPackage ../all-pkgs/m/mtr { };

inherit (callPackages ../all-pkgs/m/mumble {
  jackSupport = config.jack or false;
  speechdSupport = config.mumble.speechdSupport or false;
  pulseSupport = config.pulseaudio or false;
  iceSupport = config.murmur.iceSupport or true;
})
  mumble
  mumble_git
  murmur
  murmur_git;

musepack = callPackage ../all-pkgs/m/musepack { };

musl = callPackage ../all-pkgs/m/musl { };

mutter = callPackage ../all-pkgs/m/mutter { };

mxml = callPackage ../all-pkgs/m/mxml { };

nano = callPackage ../all-pkgs/n/nano { };

nasm = callPackage ../all-pkgs/n/nasm { };

nautilus = callPackage ../all-pkgs/n/nautilus { };

ncdc = callPackage ../all-pkgs/n/ncdc { };

ncmpc = callPackage ../all-pkgs/n/ncmpc { };

ncmpcpp = callPackage ../all-pkgs/n/ncmpcpp { };

ncurses = callPackage ../all-pkgs/g/gpm-ncurses { };

net-snmp = callPackage ../all-pkgs/n/net-snmp { };

net-tools = callPackage ../all-pkgs/n/net-tools { };

nettle = callPackage ../all-pkgs/n/nettle { };

networkmanager = callPackage ../all-pkgs/n/networkmanager { };

networkmanager-applet = callPackage ../all-pkgs/n/networkmanager-applet { };

networkmanager-l2tp = callPackage ../all-pkgs/n/networkmanager-l2tp { };

networkmanager-openconnect = callPackage ../all-pkgs/n/networkmanager-openconnect { };

networkmanager-openvpn = callPackage ../all-pkgs/n/networkmanager-openvpn { };

networkmanager-pptp = callPackage ../all-pkgs/n/networkmanager-pptp { };

networkmanager-vpnc = callPackage ../all-pkgs/n/networkmanager-vpnc { };

nfacct = callPackage ../all-pkgs/n/nfacct { };

nfs-utils = callPackage ../all-pkgs/n/nfs-utils { };

nftables = callPackage ../all-pkgs/n/nftables { };

nghttp2_full = callPackage ../all-pkgs/n/nghttp2 { };
nghttp2_lib = callPackageAlias "nghttp2_full" {
  prefix = "lib";
};

nginx = callPackage ../all-pkgs/n/nginx { };
nginx_unstable = callPackageAlias "nginx" {
  channel = "unstable";
};

ninja = callPackage ../all-pkgs/n/ninja { };

nix = callPackage ../all-pkgs/n/nix { };

nix_dev = callPackageAlias "nix" {
  channel = "dev";
};

nmap = callPackage ../all-pkgs/n/nmap { };

nodejs = callPackage ../all-pkgs/n/nodejs { };

noise = callPackage ../all-pkgs/n/noise { };

nomad = pkgs.goPackages.nomad.bin // { outputs = [ "bin" ]; };

npth = callPackage ../all-pkgs/n/npth { };

nspr = callPackage ../all-pkgs/n/nspr { };

nss = callPackage ../all-pkgs/n/nss { };

nss_wrapper = callPackage ../all-pkgs/n/nss_wrapper { };

ntfs-3g = callPackage ../all-pkgs/n/ntfs-3g { };

ntp = callPackage ../all-pkgs/n/ntp { };

numactl = callPackage ../all-pkgs/n/numactl { };

nvidia-cuda-toolkit_7-5 = callPackage ../all-pkgs/n/nvidia-cuda-toolkit {
  channel = "7.5";
};
#nvidia-cuda-toolkit_8-0 = callPackage ../all-pkgs/n/nvidia-cuda-toolkit {
#  channel = "8.0";
#};
nvidia-cuda-toolkit = callPackageAlias "nvidia-cuda-toolkit_7-5" { };

nvidia-gpu-deployment-kit =
  callPackage ../all-pkgs/n/nvidia-gpu-deployment-kit { };

nvidia-settings = callPackage ../all-pkgs/n/nvidia-settings { };

nvidia-video-codec-sdk = callPackage ../all-pkgs/n/nvidia-video-codec-sdk { };

obexftp = callPackage ../all-pkgs/o/obexftp { };

oniguruma = callPackage ../all-pkgs/o/oniguruma { };

openldap = callPackage ../all-pkgs/o/openldap { };

openntpd = callPackage ../all-pkgs/o/openntpd { };

openobex = callPackage ../all-pkgs/o/openobex { };

opensmtpd = callPackage ../all-pkgs/o/opensmtpd { };

opensmtpd-extras = callPackage ../all-pkgs/o/opensmtpd-extras { };

openssh = callPackage ../all-pkgs/o/openssh { };

openssl = callPackage ../all-pkgs/o/openssl { };
openssl_1-0-2 = callPackageAlias "openssl" {
  channel = "1.0.2";
};
openssl_1-1-0 = callPackageAlias "openssl" {
  channel = "1.1.0";
};

openvpn = callPackage ../all-pkgs/o/openvpn { };

opus = callPackage ../all-pkgs/o/opus { };

opus-tools = callPackage ../all-pkgs/o/opus-tools { };

opusfile = callPackage ../all-pkgs/o/opusfile { };

orbit2 = callPackage ../all-pkgs/o/orbit2 { };

orc = callPackage ../all-pkgs/o/orc { };

p7zip = callPackage ../all-pkgs/p/p7zip { };

pam = callPackage ../all-pkgs/p/pam { };

pango = callPackage ../all-pkgs/p/pango { };

pangomm = callPackage ../all-pkgs/p/pangomm { };

pangox-compat = callPackage ../all-pkgs/p/pangox-compat { };

parallel = callPackage ../all-pkgs/p/parallel { };

patchelf = callPackage ../all-pkgs/p/patchelf { };

patchutils = callPackage ../all-pkgs/p/patchutils { };

pavucontrol = callPackage ../all-pkgs/p/pavucontrol { };

pciutils = callPackage ../all-pkgs/p/pciutils { };

pcre = callPackage ../all-pkgs/p/pcre { };

pcre2 = callPackage ../all-pkgs/p/pcre2 { };

pcsc-lite_full = callPackage ../all-pkgs/p/pcsc-lite {
  libOnly = false;
};
pcsc-lite_lib = callPackageAlias "pcsc-lite_full" {
  libOnly = true;
};

perl = callPackage ../all-pkgs/p/perl { };

pgbouncer = callPackage ../all-pkgs/p/pgbouncer { };

pinentry = callPackage ../all-pkgs/p/pinentry { };

pkcs11-helper = callPackage ../all-pkgs/p/pkcs11-helper { };

pkg-config = callPackage ../all-pkgs/p/pkgconfig { };

pkgconf = callPackage ../all-pkgs/p/pkgconf { };
pkgconfig = callPackageAlias "pkgconf" { };

plymouth = callPackage ../all-pkgs/p/plymouth { };

pngcrush = callPackage ../all-pkgs/p/pngcrush { };

polkit = callPackage ../all-pkgs/p/polkit { };

poppler_qt = callPackageAlias "poppler" {
  suffix = "qt5";
  qt5 = pkgs.qt5;
};
poppler_utils = callPackageAlias "poppler" {
  suffix = "utils";
  utils = true;
};
poppler = callPackage ../all-pkgs/p/poppler {
  qt5 = null;
};

postgresql = callPackage ../all-pkgs/p/postgresql { };
postgresql_lib = callPackageAlias "postgresql" { };
postgresql_95 = callPackageAlias "postgresql" {
  channel = "9.5";
};
postgresql_94 = callPackageAlias "postgresql" {
  channel = "9.4";
};
postgresql_93 = callPackageAlias "postgresql" {
  channel = "9.3";
};
postgresql_92 = callPackageAlias "postgresql" {
  channel = "9.2";
};
postgresql_91 = callPackageAlias "postgresql" {
  channel = "9.1";
};

potrace = callPackage ../all-pkgs/p/potrace { };

powertop = callPackage ../all-pkgs/p/powertop { };

procps = callPackageAlias "procps-ng" { };

procps-ng = callPackage ../all-pkgs/p/procps-ng { };

prometheus = pkgs.goPackages.prometheus.bin // { outputs = [ "bin" ]; };

protobuf-c = callPackage ../all-pkgs/p/protobuf-c { };

protobuf-cpp = callPackage ../all-pkgs/p/protobuf-cpp { };

psmisc = callPackage ../all-pkgs/p/psmisc { };

pth = callPackage ../all-pkgs/p/pth { };

pugixml = callPackage ../all-pkgs/p/pugixml { };

pulseaudio_full = callPackage ../all-pkgs/p/pulseaudio { };
pulseaudio_lib = callPackageAlias "pulseaudio_full" {
  prefix = "lib";
};

python27 = callPackage ../all-pkgs/p/python {
  channel = "2.7";
  self = callPackageAlias "python27" { };
};
python33 = callPackage ../all-pkgs/p/python {
  channel = "3.3";
  self = callPackageAlias "python33" { };
};
python34 = callPackage ../all-pkgs/p/python {
  channel = "3.4";
  self = callPackageAlias "python34" { };
};
python35 = hiPrio (callPackage ../all-pkgs/p/python {
  channel = "3.5";
  self = callPackageAlias "python35" { };
});
python36 = callPackage ../all-pkgs/p/python {
  channel = "3.6";
  self = callPackageAlias "python36" { };
};
#pypy = callPackage ../all-pkgs/p/pypy {
#  self = callPackageAlias "pypy" { };
#};
python2 = callPackageAlias "python27" { };
python3 = callPackageAlias "python35" { };
python = callPackageAlias "python2" { };

python27Packages = hiPrioSet (recurseIntoAttrs (callPackage ../top-level/python-packages.nix {
  python = callPackageAlias "python27" { };
  self = callPackageAlias "python27Packages" { };
}));
python33Packages = callPackage ../top-level/python-packages.nix {
  python = callPackageAlias "python33" { };
  self = callPackageAlias "python33Packages" { };
};
python34Packages = callPackage ../top-level/python-packages.nix {
  python = callPackageAlias "python34" { };
  self = callPackageAlias "python34Packages" { };
};
python35Packages = recurseIntoAttrs (callPackage ../top-level/python-packages.nix {
  python = callPackageAlias "python35" { };
  self = callPackageAlias "python35Packages" { };
});
python36Packages = recurseIntoAttrs (callPackage ../top-level/python-packages.nix {
  python = callPackageAlias "python36" { };
  self = callPackageAlias "python36Packages" { };
});
#pypyPackages = recurseIntoAttrs (callPackage ../top-level/python-packages.nix {
#  python = callPackageAlias "pypy" { };
#  self = callPackageAlias "pypyPackages" { };
#});
python2Packages = callPackageAlias "python27Packages" { };
python3Packages = callPackageAlias "python35Packages" { };
pythonPackages = callPackageAlias "python2Packages" { };

qbittorrent = callPackage ../all-pkgs/q/qbittorrent { };

qca = callPackage ../all-pkgs/q/qca { };

qjackctl = callPackage ../all-pkgs/q/qjackctl { };

qrencode = callPackage ../all-pkgs/q/qrencode { };

qt4 = callPackage ../all-pkgs/q/qt/4 { };

qt5 = callPackage ../all-pkgs/q/qt/5.x.nix { };

quassel = callPackage ../all-pkgs/q/quassel rec {
  monolithic = true;
  daemon = false;
  client = false;
};
quasselDaemon = pkgs.quassel.override {
  monolithic = false;
  daemon = true;
  client = false;
  tag = "-daemon";
};
quasselClient = hiPrio (pkgs.quassel.override {
  monolithic = false;
  daemon = false;
  client = true;
  tag = "-client";
});

quazip = callPackage ../all-pkgs/q/quazip { };

radvd = callPackage ../all-pkgs/r/radvd { };

rapidjson = callPackage ../all-pkgs/r/rapidjson { };

raptor2 = callPackage ../all-pkgs/r/raptor2 { };

re2c = callPackage ../all-pkgs/r/re2c { };

readline = callPackage ../all-pkgs/r/readline { };

recode = callPackage ../all-pkgs/r/recode { };

redis = callPackage ../all-pkgs/r/redis { };

resolv_wrapper = callPackage ../all-pkgs/r/resolv_wrapper { };

rest = callPackage ../all-pkgs/r/rest { };

rfkill = callPackage ../all-pkgs/r/rfkill { };

rocksdb = callPackage ../all-pkgs/r/rocksdb { };

rpm = callPackage ../all-pkgs/r/rpm { };

rtkit = callPackage ../all-pkgs/r/rtkit { };

rtmpdump = callPackage ../all-pkgs/r/rtmpdump { };

rtorrent = callPackage ../all-pkgs/r/rtorrent { };

ruby = callPackage ../all-pkgs/r/ruby { };

rustc = hiPrio (callPackage ../all-pkgs/r/rustc { });
#rustc_beta = callPackageAlias "rustc" {
#  channel = "beta";
#};
#rustc_dev = callPackageAlias "rustc" {
#  channel = "dev";
#};

rustc_bootstrap = lowPrio (callPackage ../all-pkgs/r/rustc/bootstrap.nix { });

sakura = callPackage ../all-pkgs/s/sakura { };

samba_full = callPackage ../all-pkgs/s/samba { };
samba_client = callPackageAlias "samba_full" {
  type = "client";
};

scons = pkgs.pythonPackages.scons;

screen = callPackage ../all-pkgs/s/screen { };

scrot = callPackage ../all-pkgs/s/scrot { };

# TODO SDL is a clusterfuck that needs to be fixed / renamed
SDL = callPackage ../all-pkgs/s/SDL_1 { };

SDL_image = callPackage ../all-pkgs/s/SDL_1_image { };

SDL_2 = callPackage ../all-pkgs/s/SDL { };

SDL_2_image = callPackage ../all-pkgs/s/SDL_image { };

sdparm = callPackage ../all-pkgs/s/sdparm { };

seabios = callPackage ../all-pkgs/s/seabios { };

seahorse = callPackage ../all-pkgs/s/seahorse { };

serd = callPackage ../all-pkgs/s/serd { };

serf = callPackage ../all-pkgs/s/serf { };

sg3-utils = callPackage ../all-pkgs/s/sg3-utils { };

shared_mime_info = callPackage ../all-pkgs/s/shared-mime-info { };

sharutils = callPackage ../all-pkgs/s/sharutils { };

shntool = callPackage ../all-pkgs/s/shntool { };

smartmontools = callPackage ../all-pkgs/s/smartmontools { };

snappy = callPackage ../all-pkgs/s/snappy { };

sl = callPackage ../all-pkgs/s/sl { };

slock = callPackage ../all-pkgs/s/slock { };

socket_wrapper = callPackage ../all-pkgs/s/socket_wrapper { };

sord = callPackage ../all-pkgs/s/sord { };

sox = callPackage ../all-pkgs/s/sox {
  amrnb = null;
  amrwb = null;
};

soxr = callPackage ../all-pkgs/s/soxr { };

spectrwm = callPackage ../all-pkgs/s/spectrwm { };

speexdsp = callPackage ../all-pkgs/s/speexdsp { };

spice = callPackage ../all-pkgs/s/spice { };

spice-protocol = callPackage ../all-pkgs/s/spice-protocol { };

spidermonkey = callPackage ../all-pkgs/s/spidermonkey { };
spidermonkey_45 = callPackageAlias "spidermonkey" {
  channel = "45";
};
spidermonkey_24 = callPackageAlias "spidermonkey" {
  channel = "24";
};
spidermonkey_17 = callPackageAlias "spidermonkey" {
  channel = "17";
};

split2flac = callPackage ../all-pkgs/s/split2flac { };

sqlheavy = callPackage ../all-pkgs/s/sqlheavy { };

sqlite = callPackage ../all-pkgs/s/sqlite { };

squashfs-tools = callPackage ../all-pkgs/s/squashfs-tools { };

sratom = callPackage ../all-pkgs/s/sratom { };

sssd = callPackage ../all-pkgs/s/sssd { };

st = callPackage ../all-pkgs/s/st {
  config = config.st.config or null;
  configFile = config.st.configFile or null;
};

#steamPackages = callPackage ../all-pkgs/s/steam { };
#steam = steamPackages.steam-chrootenv.override {
#  # DEPRECATED
#  withJava = config.steam.java or false;
#  withPrimus = config.steam.primus or false;
#};

strace = callPackage ../all-pkgs/s/strace { };

sublime-text = callPackage ../all-pkgs/s/sublime-text { };

subversion = callPackage ../all-pkgs/s/subversion { };
subversion_1_9 = callPackageAlias "subversion" {
  channel = "1.9";
};
subversion_1_8 = callPackageAlias "subversion" {
  channel = "1.8";
};

sudo = callPackage ../all-pkgs/s/sudo { };

sushi = callPackage ../all-pkgs/s/sushi { };

swig_2 = callPackageAlias "swig" {
  channel = "2";
};
swig_3 = callPackageAlias "swig" {
  channel = "3";
};
swig = callPackage ../all-pkgs/s/swig { };

sydent = pkgs.python2Packages.sydent;

synapse = pkgs.python2Packages.synapse;

syncthing = pkgs.goPackages.syncthing.bin // { outputs = [ "bin" ]; };

syslinux = callPackage ../all-pkgs/s/syslinux { };

sysstat = callPackage ../all-pkgs/s/sysstat { };

# TODO: Rename back to systemd once depedencies are sorted
systemd_full = callPackage ../all-pkgs/s/systemd { };
systemd_lib = callPackageAlias "systemd_full" {
  type = "lib";
};

taglib = callPackage ../all-pkgs/t/taglib { };

talloc = callPackage ../all-pkgs/t/talloc { };

tcl_8-5 = callPackage ../all-pkgs/t/tcl {
  channel = "8.5";
};
tcl_8-6 = callPackage ../all-pkgs/t/tcl {
  channel = "8.6";
};
tcl = callPackageAlias "tcl_8-6" { };

tcp-wrappers = callPackage ../all-pkgs/t/tcp-wrappers { };

tdb = callPackage ../all-pkgs/t/tdb { };

teamspeak_client = callPackage ../all-pkgs/t/teamspeak/client.nix { };
teamspeak_server = callPackage ../all-pkgs/t/teamspeak/server.nix { };

tesseract = callPackage ../all-pkgs/t/tesseract { };

tevent = callPackage ../all-pkgs/t/tevent { };

texinfo = callPackage ../all-pkgs/t/texinfo { };

thermal_daemon = callPackage ../all-pkgs/t/thermal_daemon { };

thin-provisioning-tools = callPackage ../all-pkgs/t/thin-provisioning-tools { };

tinc_1_0 = callPackage ../all-pkgs/t/tinc { channel = "1.0"; };
tinc_1_1 = callPackage ../all-pkgs/t/tinc { channel = "1.1"; };

tk_8-5 = callPackage ../all-pkgs/t/tk {
  channel = "8.5";
};
tk_8-6 = callPackage ../all-pkgs/t/tk {
  channel = "8.6";
};
tk = callPackageAlias "tk_8-6" { };

tmux = callPackage ../all-pkgs/t/tmux { };

tor = callPackage ../all-pkgs/t/tor { };

totem-pl-parser = callPackage ../all-pkgs/t/totem-pl-parser { };

tracker = callPackage ../all-pkgs/t/tracker { };

tslib = callPackage ../all-pkgs/t/tslib { };

tzdata = callPackage ../all-pkgs/t/tzdata { };

udisks = callPackage ../all-pkgs/u/udisks { };

uefi-shell = callPackage ../all-pkgs/u/uefi-shell { };

ufraw = callPackage ../all-pkgs/u/ufraw { };

uhub = callPackage ../all-pkgs/u/uhub { };

uid_wrapper = callPackage ../all-pkgs/u/uid_wrapper { };

unbound = callPackage ../all-pkgs/u/unbound { };

unicode-character-database =
  callPackage ../all-pkgs/u/unicode-character-database { };

unrar = callPackage ../all-pkgs/u/unrar { };

upower = callPackage ../all-pkgs/u/upower { };

usbmuxd = callPackage ../all-pkgs/u/usbmuxd { };

util-linux_full = callPackage ../all-pkgs/u/util-linux { };
util-linux_lib = callPackageAlias "util-linux_full" {
  type = "lib";
};

v4l-utils = callPackage ../all-pkgs/v/v4l-utils {
  channel = "utils";
};
v4l_lib = callPackageAlias "v4l-utils" {
  channel = "lib";
};

vaapi-intel = callPackage ../all-pkgs/v/vaapi-intel { };

vala = callPackage ../all-pkgs/v/vala { };

vault = pkgs.goPackages.vault.bin // { outputs = [ "bin" ]; };

vim = callPackage ../all-pkgs/v/vim { };

vino = callPackage ../all-pkgs/v/vino { };

vlc = callPackage ../all-pkgs/v/vlc { };

vobsub2srt = callPackage ../all-pkgs/v/vobsub2srt { };

vorbis-tools = callPackage ../all-pkgs/v/vorbis-tools { };

vte = callPackage ../all-pkgs/v/vte { };

w3m = callPackage ../all-pkgs/w/w3m { };

waf = callPackage ../all-pkgs/w/waf { };

wavpack = callPackage ../all-pkgs/w/wavpack { };

wayland = callPackage ../all-pkgs/w/wayland { };

wayland-protocols = callPackage ../all-pkgs/w/wayland-protocols { };

webkitgtk = callPackage ../all-pkgs/w/webkitgtk { };

wget = callPackage ../all-pkgs/w/wget { };

which = callPackage ../all-pkgs/w/which { };

wiredtiger = callPackage ../all-pkgs/w/wiredtiger { };

wireguard = callPackage ../all-pkgs/w/wireguard {
  kernel = null;
};

wxGTK = callPackage ../all-pkgs/w/wxGTK { };

x264 = callPackage ../all-pkgs/x/x264 { };

x265 = callPackage ../all-pkgs/x/x265 { };

xdg-user-dirs = callPackage ../all-pkgs/x/xdg-user-dirs { };

xdg-utils = callPackage ../all-pkgs/x/xdg-utils { };

xf86-input-mtrack = callPackage ../all-pkgs/x/xf86-input-mtrack { };

xf86-input-wacom = callPackage ../all-pkgs/x/xf86-input-wacom { };

xfe = callPackage ../all-pkgs/x/xfe { };

xfsprogs = callPackage ../all-pkgs/x/xfsprogs { };

xfsprogs_lib = pkgs.xfsprogs.lib;

xine-lib = callPackage ../all-pkgs/x/xine-lib { };

xine-ui = callPackage ../all-pkgs/x/xine-ui { };

xmlto = callPackage ../all-pkgs/x/xmlto { };

xmltoman = callPackage ../all-pkgs/x/xmltoman { };

xorg = recurseIntoAttrs (
  lib.callPackagesWith pkgs ../all-pkgs/x/xorg/default.nix {
    inherit (pkgs)
      asciidoc
      autoconf
      automake
      autoreconfHook
      bison
      dbus
      expat
      fetchurl
      fetchgit
      fetchpatch
      flex
      fontconfig
      freetype
      gperf
      intltool
      libdrm
      libevdev
      libinput
      libpng
      libtool
      libunwind
      libxslt
      m4
      makeWrapper
      mcpp
      mesa_drivers
      mtdev
      openssl
      perl
      pkgconfig
      python
      spice-protocol
      stdenv
      systemd_lib
      tradcpp
      util-linux_lib
      xmlto
      zlib;
    mesa = pkgs.mesa_noglu;
  }
);

xz = callPackage ../all-pkgs/x/xz { };

yaml-cpp = callPackage ../all-pkgs/y/yaml-cpp { };

yasm = callPackage ../all-pkgs/y/yasm { };

yelp-tools = callPackage ../all-pkgs/y/yelp-tools { };

yelp-xsl = callPackage ../all-pkgs/y/yelp-xsl { };

zeitgeist = callPackage ../all-pkgs/z/zeitgeist { };

zenity_generics = overrides: callPackage ../all-pkgs/z/zenity ({
  webkitgtk = null;
} // overrides);
zenity_3-20 = pkgs.zenity_generics {
  channel = "3.20";
};
zenity = callPackageAlias "zenity_3-20" { };

zeromq = callPackage ../all-pkgs/z/zeromq { };

zip = callPackage ../all-pkgs/z/zip { };

zita-convolver = callPackage ../all-pkgs/z/zita-convolver { };

zita-resampler = callPackage ../all-pkgs/z/zita-resampler { };

zlib = callPackage ../all-pkgs/z/zlib { };

zsh = callPackage ../all-pkgs/z/zsh { };

zstd = callPackage ../all-pkgs/z/zstd { };

################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
############################### END ALL PKGS ###################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
#
  desktop_file_utils = callPackage ../tools/misc/desktop-file-utils { };
#
  dnssec-root = callPackage ../data/misc/dnssec-root { };
#
  dnstop = callPackage ../tools/networking/dnstop { };
#
  diffoscope = callPackage ../tools/misc/diffoscope { };
#
  docbook2x = callPackage ../tools/typesetting/docbook2x { };
#
  fdk_aac = callPackage ../development/libraries/fdk-aac { };
#
  fontforge = lowPrio (callPackage ../tools/misc/fontforge { });
#
  gnulib = callPackage ../development/tools/gnulib { };

  grub2 = callPackage ../tools/misc/grub/2.0x.nix { };

  grub2_efi = callPackageAlias "grub2" {
    efiSupport = true;
  };
#
  iftop = callPackage ../tools/networking/iftop { };
#
  less = callPackage ../tools/misc/less { };
#
  most = callPackage ../tools/misc/most { };
#
  ldns = callPackage ../development/libraries/ldns { };
#
  libconfig = callPackage ../development/libraries/libconfig { };
#
  liboauth = callPackage ../development/libraries/liboauth { };
#
  man = callPackage ../tools/misc/man { };
#
  memtest86plus = callPackage ../tools/misc/memtest86+ { };
#
  netcat = callPackage ../tools/networking/netcat { };
#
  npapi_sdk = callPackage ../development/libraries/npapi-sdk { };
#
  openresolv = callPackage ../tools/networking/openresolv { };

  opensp = callPackage ../tools/text/sgml/opensp { };

  spCompat = callPackage ../tools/text/sgml/opensp/compat.nix { };
#
  #parted = callPackage ../tools/misc/parted { hurd = null; };
#
  ppp = callPackage ../tools/networking/ppp { };

  pptp = callPackage ../tools/networking/pptp {};
#
  qpdf = callPackage ../development/libraries/qpdf { };
#
  rng_tools = callPackage ../tools/security/rng-tools { };
#
  strongswan = callPackage ../tools/networking/strongswan { };
#
  tcpdump = callPackage ../tools/networking/tcpdump { };
#
  trousers = callPackage ../tools/security/trousers { };
#
  vpnc = callPackage ../tools/networking/vpnc { };

  openconnect = callPackageAlias "openconnect_openssl" { };

  openconnect_openssl = callPackage ../tools/networking/openconnect.nix {
    gnutls = null;
  };
#
  xl2tpd = callPackage ../tools/networking/xl2tpd { };
#
  time = callPackage ../tools/misc/time { };
#
  tre = callPackage ../development/libraries/tre { };
#
  unzip = callPackage ../tools/archivers/unzip { };

  systemd-cryptsetup-generator = callPackage ../os-specific/linux/systemd/cryptsetup-generator.nix { };
#
  gcc = callPackageAlias "gcc6" { };
#
  gcc48 = lowPrio (wrapCC (callPackage ../development/compilers/gcc/4.8 {
    noSysDirs = true;

    # PGO seems to speed up compilation by gcc by ~10%, see #445 discussion
    profiledCompiler = true;

    # When building `gcc.crossDrv' (a "Canadian cross", with host == target
    # and host != build), `cross' must be null but the cross-libc must still
    # be passed.
    cross = null;
    libcCross = null;

    isl = pkgs.isl_0_14;
  }));
#
  gcc5 = lowPrio (wrapCC (callPackage ../development/compilers/gcc/5 {
    noSysDirs = true;

    # PGO seems to speed up compilation by gcc by ~10%, see #445 discussion
    profiledCompiler = true;

    # When building `gcc.crossDrv' (a "Canadian cross", with host == target
    # and host != build), `cross' must be null but the cross-libc must still
    # be passed.
    cross = null;
    libcCross = null;
  }));

  gcc6 = lowPrio (wrapCC (callPackage ../development/compilers/gcc/6 {
    noSysDirs = true;

    # PGO seems to speed up compilation by gcc by ~10%, see #445 discussion
    profiledCompiler = true;

    # When building `gcc.crossDrv' (a "Canadian cross", with host == target
    # and host != build), `cross' must be null but the cross-libc must still
    # be passed.
    cross = null;
    libcCross = null;
  }));
#
  haskell = callPackage ./haskell-packages.nix { };
#
  haskellPackages = pkgs.haskell.packages.ghc7103.override {
    overrides = config.haskellPackageOverrides or (self: super: {});
  };
#
#  icedtea7_web = callPackage ../development/compilers/icedtea-web {
#    jdk = jdk7;
#    xulrunner = firefox-unwrapped;
#  };
#
  icedtea8_web = callPackage ../development/compilers/icedtea-web {
    jdk = pkgs.jdk8;
    xulrunner = pkgs.firefox-unwrapped;
  };

  icedtea_web = pkgs.icedtea8_web;
#
#  openjdk7-bootstrap = callPackage ../development/compilers/openjdk/bootstrap.nix { version = "7"; };
  openjdk8-bootstrap = callPackage ../development/compilers/openjdk/bootstrap.nix { version = "8"; };
#
#  openjdk7-make-bootstrap = callPackage ../development/compilers/openjdk/make-bootstrap.nix {
#    openjdk = openjdk7.override { minimal = true; };
#  };
  openjdk8-make-bootstrap = callPackage ../development/compilers/openjdk/make-bootstrap.nix {
    openjdk = pkgs.openjdk8.override { minimal = true; };
  };
#
#  openjdk7 = callPackage ../development/compilers/openjdk/7.nix {
#    bootjdk = openjdk7-bootstrap;
#  };
#  openjdk7_jdk = openjdk7 // { outputs = [ "out" ]; };
#  openjdk7_jre = openjdk7.jre // { outputs = [ "jre" ]; };
#
  openjdk8 = callPackage ../development/compilers/openjdk/8.nix {
    bootjdk = pkgs.openjdk8-bootstrap;
  };
  openjdk8_jdk = pkgs.openjdk8 // { outputs = [ "out" ]; };
  openjdk8_jre = pkgs.openjdk8.jre // { outputs = [ "jre" ]; };

  openjdk = callPackageAlias "openjdk8" { };
#
#  java7 = openjdk7;
#  jdk7 = java7 // { outputs = [ "out" ]; };
#  jre7 = java7.jre // { outputs = [ "jre" ]; };
#
  java8 = callPackageAlias "openjdk8" { };
  jdk8 = pkgs.java8 // { outputs = [ "out" ]; };
  jre8 = pkgs.java8.jre // { outputs = [ "jre" ]; };
#
  java = callPackageAlias "java8" { };
  jdk = pkgs.java // { outputs = [ "out" ]; };
  jre = pkgs.java.jre // { outputs = [ "jre" ]; };
#
#  mono = callPackage ../development/compilers/mono { };
#
#  lua5_2 = callPackage ../development/interpreters/lua-5/5.2.nix { };
#  lua5_2_compat = callPackage ../development/interpreters/lua-5/5.2.nix {
#    compat = true;
#  };
  lua5_3 = callPackage ../development/interpreters/lua-5/5.3.nix { };
  lua5_3_compat = callPackage ../development/interpreters/lua-5/5.3.nix {
    compat = true;
  };
  lua5 = callPackageAlias "lua5_3_compat" { };
  lua = callPackageAlias "lua5" { };
#
#  lua52Packages = callPackage ./lua-packages.nix { lua = lua5_2; };
  lua53Packages = callPackage ./lua-packages.nix {
    lua = callPackageAlias "lua5_3" { };
  };
  luaPackages = callPackageAlias "lua53Packages" { };
#
  php = pkgs.php70;
#
#  phpPackages = recurseIntoAttrs (callPackage ./php-packages.nix {});
#
  inherit (callPackages ../development/interpreters/php { })
    php70;
#
  ant = callPackageAlias "apacheAnt" { };

  apacheAnt = callPackage ../development/tools/build-managers/apache-ant { };
#
  autoconf-archive = callPackage ../development/tools/misc/autoconf-archive { };
#
  automoc4 = callPackage ../development/tools/misc/automoc4 { };
#
  binutils = callPackage ../development/tools/misc/binutils { };
#
  doxygen = callPackage ../development/tools/documentation/doxygen {
    qt4 = null;
  };
#
  gnome_doc_utils = callPackage ../development/tools/documentation/gnome-doc-utils {};
#
  inotify-tools = callPackage ../development/tools/misc/inotify-tools { };
#
  ltrace = callPackage ../development/tools/misc/ltrace { };
#
  speedtest-cli = callPackage ../tools/networking/speedtest-cli { };
#
  gdb = callPackage ../development/tools/misc/gdb {
    guile = null;
  };
#
  valgrind = callPackage ../development/tools/analysis/valgrind { };
#
  a52dec = callPackage ../development/libraries/a52dec { };
#
  aalib = callPackage ../development/libraries/aalib { };
#
  accelio = callPackage ../development/libraries/accelio { };
#
  celt = callPackage ../development/libraries/celt {};
  celt_0_7 = callPackage ../development/libraries/celt/0.7.nix {};
  celt_0_5_1 = callPackage ../development/libraries/celt/0.5.1.nix {};
#
  cppunit = callPackage ../development/libraries/cppunit { };

  faad2 = callPackage ../development/libraries/faad2 { };
#
  ffms = callPackage ../development/libraries/ffms { };
#
  flite = callPackage ../development/libraries/flite { };
#
  fltk13 = callPackage ../development/libraries/fltk/fltk13.nix { };
#
cfitsio = callPackage ../development/libraries/cfitsio { };
#
  fontconfig = callPackage ../development/libraries/fontconfig { };

  fontconfig-ultimate = callPackage ../development/libraries/fontconfig-ultimate {};
#
  makeFontsConf = let fontconfig_ = pkgs.fontconfig; in {fontconfig ? fontconfig_, fontDirectories}:
    callPackage ../development/libraries/fontconfig/make-fonts-conf.nix {
      inherit fontconfig fontDirectories;
    };
#
  makeFontsCache = let fontconfig_ = pkgs.fontconfig; in {fontconfig ? fontconfig_, fontDirectories}:
    callPackage ../development/libraries/fontconfig/make-fonts-cache.nix {
      inherit fontconfig fontDirectories;
    };

  frei0r = callPackage ../development/libraries/frei0r { };

  fribidi = callPackage ../development/libraries/fribidi { };
#
  giblib = callPackage ../development/libraries/giblib { };
#
  glibc = callPackage ../development/libraries/glibc { };

  # Only supported on Linux
  glibcLocales = callPackage ../development/libraries/glibc/locales.nix { };
#
  gmime = callPackage ../development/libraries/gmime { };
#
  gom = callPackage ../all-pkgs/g/gom { };
#
  gpgme = callPackage ../development/libraries/gpgme { };
#
  gsl = callPackage ../development/libraries/gsl { };
#
  gss = callPackage ../development/libraries/gss { };
#
  gtkLibs = {
    inherit (pkgs) glib glibmm atk atkmm cairo pango pangomm gdk-pixbuf gtk2
      gtkmm2;
  };
#
  gts = callPackage ../development/libraries/gts { };
#
  ilmbase = callPackage ../development/libraries/ilmbase { };
#
  imlib2 = callPackage ../development/libraries/imlib2 { };

  ijs = callPackage ../development/libraries/ijs { };
#
  jasper = callPackage ../development/libraries/jasper { };
#
  jbig2dec = callPackage ../development/libraries/jbig2dec { };

  jbigkit = callPackage ../development/libraries/jbigkit { };
#
  lcms = callPackageAlias "lcms1" { };

  lcms1 = callPackage ../development/libraries/lcms { };

  lcms2 = callPackage ../development/libraries/lcms2 { };
#
  libaacs = callPackage ../development/libraries/libaacs { };

  libao = callPackage ../development/libraries/libao { };
#
  libasyncns = callPackage ../development/libraries/libasyncns { };
#
  libbdplus = callPackage ../development/libraries/libbdplus { };

  libbs2b = callPackage ../development/libraries/audio/libbs2b { };
#
  libcaca = callPackage ../development/libraries/libcaca { };
#
  libcddb = callPackage ../development/libraries/libcddb { };

  libcdio = callPackage ../development/libraries/libcdio { };
#
  libcdr = callPackage ../development/libraries/libcdr { lcms = callPackageAlias "lcms2" { }; };
#
  libdaemon = callPackage ../development/libraries/libdaemon { };
#
  libdiscid = callPackage ../development/libraries/libdiscid { };
#
  libdvbpsi = callPackage ../development/libraries/libdvbpsi { };
#
  libdvdcss = callPackage ../development/libraries/libdvdcss { };

  libdvdnav = callPackage ../development/libraries/libdvdnav { };
#
  libdvdread = callPackage ../development/libraries/libdvdread { };
#
  libgtop = callPackage ../development/libraries/libgtop {};
#
  libexif = callPackage ../development/libraries/libexif { };
#
  libimobiledevice = callPackage ../development/libraries/libimobiledevice { };
#
  liblqr1 = callPackage ../development/libraries/liblqr-1 { };
#
  libmediainfo = callPackage ../development/libraries/libmediainfo { };
#
  libnatspec = callPackage ../development/libraries/libnatspec { };
#
  libndp = callPackage ../development/libraries/libndp { };
#
  libplist = callPackage ../development/libraries/libplist { };
#
  librevenge = callPackage ../development/libraries/librevenge {};

  libid3tag = callPackage ../development/libraries/libid3tag { };

  idnkit = callPackage ../development/libraries/idnkit { };

  libiec61883 = callPackage ../development/libraries/libiec61883 { };
#
  libmad = callPackage ../development/libraries/libmad { };
#
  libmikmod = callPackage ../development/libraries/libmikmod { };
#
  libmms = callPackage ../development/libraries/libmms { };
#
  libmng = callPackage ../development/libraries/libmng { };
#
  liboggz = callPackage ../development/libraries/liboggz { };
#
  libpaper = callPackage ../development/libraries/libpaper { };
#
  libpwquality = callPackage ../development/libraries/libpwquality { };
#
libstartup_notification = callPackage ../development/libraries/startup-notification { };
#
libtiff = callPackage ../development/libraries/libtiff { };

  libtiger = callPackage ../development/libraries/libtiger { };
#
  libtxc_dxtn = callPackage ../development/libraries/libtxc_dxtn { };
#
  libtxc_dxtn_s2tc = callPackage ../development/libraries/libtxc_dxtn_s2tc { };
#
  libunistring = callPackage ../development/libraries/libunistring { };

  libupnp = callPackage ../development/libraries/pupnp { };

  giflib = callPackageAlias "giflib_5_1" { };
  giflib_4_1 = callPackage ../development/libraries/giflib/4.1.nix { };
  giflib_5_1 = callPackage ../development/libraries/giflib/5.1.nix { };

  libungif = callPackage ../development/libraries/giflib/libungif.nix { };
#
  libvisio = callPackage ../development/libraries/libvisio { };

  libvisual = callPackage ../development/libraries/libvisual { };
#
  libwmf = callPackage ../development/libraries/libwmf { };
#
  libwpd = callPackage ../development/libraries/libwpd { };
#
  libwpg = callPackage ../development/libraries/libwpg { };
#
  libxmlxx = callPackage ../development/libraries/libxmlxx { };
#
  libzen = callPackage ../development/libraries/libzen { };

  log4cplus = callPackage ../development/libraries/log4cplus { };
#
  neon = callPackage ../development/libraries/neon {
    compressionSupport = true;
    sslSupport = true;
  };
#
  newt = callPackage ../development/libraries/newt { };
#
  openal = callPackageAlias "openalSoft" { };
  openalSoft = callPackage ../development/libraries/openal-soft { };
#
  opencv = callPackage ../development/libraries/opencv { };
#
  openexr = callPackage ../development/libraries/openexr { };
#
  openh264 = callPackage ../development/libraries/openh264 { };
#
  openjpeg_1 = callPackage ../development/libraries/openjpeg/1.x.nix { };
  openjpeg_2_0 = callPackage ../development/libraries/openjpeg/2.0.nix { };
  openjpeg_2_1 = callPackage ../development/libraries/openjpeg/2.1.nix { };
  openjpeg = callPackageAlias "openjpeg_2_1" { };
#
  p11_kit = callPackage ../development/libraries/p11-kit { };
#
  phonon = callPackage ../development/libraries/phonon/qt4 {};
#
  popt = callPackage ../development/libraries/popt { };

  portaudio = callPackage ../development/libraries/portaudio { };
#
  portmidi = callPackage ../development/libraries/portmidi { };
#
  rubberband = callPackage ../development/libraries/rubberband { };
#
  sbc = callPackage ../development/libraries/sbc { };
#
  schroedinger = callPackage ../development/libraries/schroedinger { };
#
  slang = callPackage ../development/libraries/slang { };
#
  soundtouch = callPackage ../development/libraries/soundtouch {};

  spandsp = callPackage ../development/libraries/spandsp {};
#
  speechd = callPackage ../development/libraries/speechd { };
#
  speex = callPackage ../development/libraries/speex { };
#
  sqlite-interactive = pkgs.sqlite;
#
  t1lib = callPackage ../development/libraries/t1lib { };
#
  telepathy_glib = callPackage ../development/libraries/telepathy/glib { };
#
  tinyxml2 = callPackage ../development/libraries/tinyxml/2.6.2.nix { };
#
unixODBC = callPackage ../development/libraries/unixODBC { };
#
  uthash = callPackage ../development/libraries/uthash { };
#
  vamp = callPackage ../development/libraries/audio/vamp { };
#
  vid-stab = callPackage ../development/libraries/vid-stab { };
#
  webrtc-audio-processing = callPackage ../development/libraries/webrtc-audio-processing { };
#
  xavs = callPackage ../development/libraries/xavs { };
#
  xmlrpc_c = callPackage ../development/libraries/xmlrpc-c { };
#
  xvidcore = callPackage ../development/libraries/xvidcore { };
#
  yajl = callPackage ../development/libraries/yajl { };
#
  zziplib = callPackage ../development/libraries/zziplib { };
#
  buildPerlPackage = callPackage ../development/perl-modules/generic { };

  perlPackages = recurseIntoAttrs (callPackage ./perl-packages.nix {
    overrides = (config.perlPackageOverrides or (p: {})) pkgs;
  });
#
  pyxml = callPackage ../development/python-modules/pyxml { };
#
  apache-httpd = callPackage ../all-pkgs/a/apache-httpd  { };

  apacheHttpdPackagesFor = apacheHttpd: self: let callPackage = pkgs.newScope self; in {
    inherit apacheHttpd;

    mod_dnssd = callPackage ../servers/http/apache-modules/mod_dnssd { };
#
#    mod_evasive = callPackage ../servers/http/apache-modules/mod_evasive { };
#
#    mod_fastcgi = callPackage ../servers/http/apache-modules/mod_fastcgi { };
#
#    mod_python = callPackage ../servers/http/apache-modules/mod_python { };
#
#    mod_wsgi = callPackage ../servers/http/apache-modules/mod_wsgi { };
#
#    php = pkgs.php.override { inherit apacheHttpd; };
#
#    subversion = pkgs.subversion.override { httpServer = true; inherit apacheHttpd; };
  };
#
  apacheHttpdPackages = pkgs.apacheHttpdPackagesFor pkgs.apacheHttpd pkgs.apacheHttpdPackages;
#
  bind = callPackage ../servers/dns/bind { };

  dnsutils = callPackageAlias "bind" {
    suffix = "tools";
  };
#
#  # Backwards compatibility.
  mod_dnssd = pkgs.apacheHttpdPackages.mod_dnssd;
#
  mariadb = callPackage ../servers/sql/mariadb { };
#
  mysql = callPackageAlias "mariadb" { };
  mysql_lib = callPackageAlias "mysql" { };
#
  softether_4_18 = callPackage ../servers/softether/4.18.nix { };
  softether = callPackageAlias "softether_4_18" { };
#
  unifi = callPackage ../servers/unifi { };
#
  zookeeper = callPackage ../servers/zookeeper { };

  zookeeper_mt = callPackage ../development/libraries/zookeeper_mt { };
#
  acpi = callPackage ../os-specific/linux/acpi { };
#
  alsa-oss = callPackage ../os-specific/linux/alsa-oss { };

  alsa-tools = callPackage ../os-specific/linux/alsa-tools { };

  microcodeAmd = callPackage ../os-specific/linux/microcode/amd.nix { };
#
  atop = callPackage ../os-specific/linux/atop { };
#
  busybox = callPackage ../os-specific/linux/busybox { };

  busyboxBootstrap = callPackageAlias "busybox" {
    enableStatic = true;
    enableMinimal = true;
    extraConfig = ''
      CONFIG_ASH y
      CONFIG_ASH_BUILTIN_ECHO y
      CONFIG_ASH_BUILTIN_TEST y
      CONFIG_ASH_OPTIMIZE_FOR_SIZE y
      CONFIG_MKDIR y
      CONFIG_TAR y
      CONFIG_UNXZ y
    '';
  };
#
  ffado_full = callPackage ../os-specific/linux/ffado { };

  ffado_lib = callPackage ../os-specific/linux/ffado {
    prefix = "lib";
  };
#
#  # -- Linux kernel expressions ------------------------------------------------
#

  kernelPatches = callPackage ../os-specific/linux/kernel/patches.nix { };

  linux_4_7 = callPackage ../os-specific/linux/kernel {
    channel = "4.7";
    kernelPatches = [ pkgs.kernelPatches.bridge_stp_helper ];
  };

  linux_testing = callPackage ../os-specific/linux/kernel {
    channel = "testing";
    kernelPatches = [ pkgs.kernelPatches.bridge_stp_helper ];
  };

  linux_bcache = callPackage ../os-specific/linux/kernel {
    channel = "bcache";
    kernelPatches = [ pkgs.kernelPatches.bridge_stp_helper ];
  };
#
#  /* Linux kernel modules are inherently tied to a specific kernel.  So
#     rather than provide specific instances of those packages for a
#     specific kernel, we have a function that builds those packages
#     for a specific kernel.  This function can then be called for
#     whatever kernel you're using. */
#
  linuxPackagesFor = { kernel }: let
    kCallPackage = pkgs.newScope kPkgs;

    kPkgs = {
      inherit kernel;

      accelio = kCallPackage ../development/libraries/accelio { };

      cryptodev = pkgs.cryptodevHeaders.override {
        onlyHeaders = false;
        inherit kernel;  # We shouldn't need this
      };

      cpupower = kCallPackage ../os-specific/linux/cpupower { };

      e1000e = kCallPackage ../os-specific/linux/e1000e {};

      #nvidia-drivers_tesla = kCallPackage ../all-pkgs/n/nvidia-drivers {
      #  channel = "tesla";
      #};
      nvidia-drivers_long-lived = kCallPackage ../all-pkgs/n/nvidia-drivers {
        channel = "long-lived";
      };
      nvidia-drivers_short-lived = kCallPackage ../all-pkgs/n/nvidia-drivers {
        channel = "short-lived";
      };
      nvidia-drivers_beta = kCallPackage ../all-pkgs/n/nvidia-drivers {
        channel = "beta";
      };

      spl = kCallPackage ../os-specific/linux/spl {
        configFile = "kernel";
        inherit (kPkgs) kernel;  # We shouldn't need this
      };

      spl_git = kCallPackage ../os-specific/linux/spl/git.nix {
        configFile = "kernel";
        inherit (kPkgs) kernel;  # We shouldn't need this
      };

      wireguard = kCallPackage ../all-pkgs/w/wireguard {
        inherit (kPkgs) kernel;
      };

      zfs = kCallPackage ../os-specific/linux/zfs {
        configFile = "kernel";
        inherit (kPkgs) kernel spl;  # We shouldn't need this
      };

      zfs_git = kCallPackage ../os-specific/linux/zfs/git.nix {
        configFile = "kernel";
        inherit (kPkgs) kernel spl_git;  # We shouldn't need this
      };

    };
  in kPkgs;
#
#  # The current default kernel / kernel modules.
  linuxPackages = pkgs.linuxPackages_4_7;
  linux = pkgs.linuxPackages.kernel;
#
#  # Update this when adding the newest kernel major version!
  linuxPackages_latest = pkgs.linuxPackages_4_7;
  linux_latest = pkgs.linuxPackages_latest.kernel;
#
#  # Build the kernel modules for the some of the kernels.
  linuxPackages_4_7 = recurseIntoAttrs (pkgs.linuxPackagesFor {
    kernel = pkgs.linux_4_7;
  });
  linuxPackages_testing = recurseIntoAttrs (pkgs.linuxPackagesFor {
    kernel = pkgs.linux_testing;
  });
  linuxPackages_bcache = recurseIntoAttrs (pkgs.linuxPackagesFor {
    kernel = pkgs.linux_bcache;
  });
  linuxPackages_custom = {version, src, configfile}:
                           let linuxPackages_self = (linuxPackagesFor (pkgs.linuxManualConfig {inherit version src configfile;
                                                                                               allowImportFromDerivation=true;})
                                                     linuxPackages_self);
                           in recurseIntoAttrs linuxPackages_self;
#
#  # A function to build a manually-configured kernel
  linuxManualConfig = pkgs.buildLinux;
  buildLinux = callPackage ../os-specific/linux/kernel/manual-config.nix {};
#
  kmod-blacklist-ubuntu = callPackage ../os-specific/linux/kmod-blacklist-ubuntu { };

  kmod-debian-aliases = callPackage ../os-specific/linux/kmod-debian-aliases { };

  libcap = callPackage ../os-specific/linux/libcap { };
#
  libnotify = callPackage ../development/libraries/libnotify { };
#
  mdadm = callPackage ../os-specific/linux/mdadm { };
#
  aggregateModules = modules:
    callPackage ../all-pkgs/k/kmod/aggregator.nix {
      inherit modules;
    };
#
  procps-old = lowPrio (callPackage ../os-specific/linux/procps { });
#
  firmware-linux-nonfree = callPackage ../os-specific/linux/firmware/firmware-linux-nonfree { };
#
  shadow = callPackage ../os-specific/linux/shadow { };
#
  spl = callPackage ../os-specific/linux/spl {
    configFile = "user";
  };
  spl_git = callPackage ../os-specific/linux/spl/git.nix {
    configFile = "user";
  };
#
  sysfsutils = callPackage ../os-specific/linux/sysfsutils { };
#
#  # In nixos, you can set systemd.package = pkgs.systemd_with_lvm2 to get
#  # LVM2 working in systemd.
  systemd_with_lvm2 = pkgs.lib.overrideDerivation pkgs.systemd_full (p: {
      name = p.name + "-with-lvm2";
      postInstall = p.postInstall + ''
        cp "${pkgs.lvm2}/lib/systemd/system-generators/"* $out/lib/systemd/system-generators
      '';
  });
#
#  # TODO(dezgeg): either refactor & use ubootTools directly, or remove completely
  ubootChooser = name: ubootTools;

  # Upstream U-Boots:
  ubootTools = callPackage ../misc/uboot {
    toolsOnly = true;
    targetPlatforms = lib.platforms.linux;
    filesToInstall = ["tools/dumpimage" "tools/mkenvimage" "tools/mkimage"];
  };
#
  usbutils = callPackage ../os-specific/linux/usbutils { };

  wirelesstools = callPackage ../os-specific/linux/wireless-tools { };

  wpa_supplicant = callPackage ../os-specific/linux/wpa_supplicant { };
#
  zfs = callPackage ../os-specific/linux/zfs {
    configFile = "user";
  };
  zfs_git = callPackage ../os-specific/linux/zfs/git.nix {
    configFile = "user";
  };
#
  cacert = callPackage ../data/misc/cacert { };
#
  cantarell_fonts = callPackage ../data/fonts/cantarell-fonts { };
#
  docbook5 = callPackage ../data/sgml+xml/schemas/docbook-5.0 { };

  docbook_sgml_dtd_31 = callPackage ../data/sgml+xml/schemas/sgml-dtd/docbook/3.1.nix { };

  docbook_sgml_dtd_41 = callPackage ../data/sgml+xml/schemas/sgml-dtd/docbook/4.1.nix { };

  docbook_xml_dtd_412 = callPackage ../data/sgml+xml/schemas/xml-dtd/docbook/4.1.2.nix { };

  docbook_xml_dtd_42 = callPackage ../data/sgml+xml/schemas/xml-dtd/docbook/4.2.nix { };

  docbook_xml_dtd_43 = callPackage ../data/sgml+xml/schemas/xml-dtd/docbook/4.3.nix { };
#
  docbook_xml_dtd_44 = callPackage ../data/sgml+xml/schemas/xml-dtd/docbook/4.4.nix { };
#
  docbook_xml_dtd_45 = callPackage ../data/sgml+xml/schemas/xml-dtd/docbook/4.5.nix { };
#
  freefont_ttf = callPackage ../data/fonts/freefont-ttf { };
#
  meslo-lg = callPackage ../data/fonts/meslo-lg {};
#
  mobile_broadband_provider_info = callPackage ../data/misc/mobile-broadband-provider-info { };
#
  sound-theme-freedesktop = callPackage ../data/misc/sound-theme-freedesktop { };
#
  unifont = callPackage ../data/fonts/unifont { };
#
  djvulibre = callPackage ../applications/misc/djvulibre { };
#
  djview = callPackage ../applications/graphics/djview { };
  djview4 = pkgs.djview;
#
  ed = callPackage ../applications/editors/ed { };
#
  fluidsynth = callPackage ../applications/audio/fluidsynth { };
#
  google_talk_plugin = callPackage ../applications/networking/browsers/mozilla-plugins/google-talk-plugin { };
#
  ladspaH = callPackage ../applications/audio/ladspa-sdk/ladspah.nix { };
#
  mcpp = callPackage ../development/compilers/mcpp { };
#
  mpg123 = callPackage ../applications/audio/mpg123 { };
#
  mujs = callPackage ../all-pkgs/m/mujs { };

  mupdf = callPackage ../all-pkgs/m/mupdf {
    openjpeg = pkgs.openjpeg_2_0;
  };
#
  ncdu = callPackage ../tools/misc/ncdu { };
#
  rsync = callPackage ../applications/networking/sync/rsync { };
#
#
  #spotify = callPackage ../applications/audio/spotify { };
#
  subunit = callPackage ../development/libraries/subunit { };
#
  telepathy_logger = callPackage ../applications/networking/instant-messengers/telepathy/logger {};

  telepathy_mission_control = callPackage ../applications/networking/instant-messengers/telepathy/mission-control { };
#
  #trezor-bridge = callPackage ../applications/networking/browsers/mozilla-plugins/trezor { };
#
  xpdf = callPackage ../applications/misc/xpdf {
    base14Fonts = "${ghostscript}/share/ghostscript/fonts";
  };

  cups_filters = callPackage ../misc/cups/filters.nix { };
#
  dblatex = callPackage ../tools/typesetting/tex/dblatex {
    enableAllFeatures = false;
  };
#
  ghostscript = callPackage ../misc/ghostscript {
    x11Support = false;
    cupsSupport = config.ghostscript.cups or true;
  };
#
  jack2_full = callPackage ../misc/jackaudio { };

  jack2_lib = callPackageAlias "jack2_full" {
    prefix = "lib";
  };
#
#
  nixos-artwork = callPackage ../data/misc/nixos-artwork { };
#
#  # All the new TeX Live is inside. See description in default.nix.
 texlive = recurseIntoAttrs
    (callPackage ../tools/typesetting/tex/texlive-new { });
  texLive = callPackageAlias "texlive" { };
#
  #wine = callPackage ../misc/emulators/wine {
  #  wineRelease = config.wine.release or "stable";
  #  wineBuild = config.wine.build or "wine32";
  #  pulseaudioSupport = config.pulseaudio or true;
  #};
  #wineStable = wine.override { wineRelease = "stable"; };
  #wineUnstable = lowPrio (wine.override { wineRelease = "unstable"; });
  #wineStaging = lowPrio (wine.override { wineRelease = "staging"; });

  #winetricks = callPackage ../misc/emulators/wine/winetricks.nix { };
#
  myEnvFun = callPackage ../misc/my-env { };
#
};

in self; in pkgs
