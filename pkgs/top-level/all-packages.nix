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

accountsservice = callPackage ../all-pkgs/accountsservice { };

acl = callPackage ../all-pkgs/acl { };

acpid = callPackage ../all-pkgs/acpid { };

adns = callPackage ../all-pkgs/adns { };

adwaita-icon-theme_3-20 = callPackage ../all-pkgs/adwaita-icon-theme {
  channel = "3.20";
};
adwaita-icon-theme = callPackageAlias "adwaita-icon-theme_3-20" { };

alsa-firmware = callPackage ../all-pkgs/alsa-firmware { };

alsa-lib = callPackage ../all-pkgs/alsa-lib { };

alsa-plugins = callPackage ../all-pkgs/alsa-plugins { };

alsa-utils = callPackage ../all-pkgs/alsa-utils { };

amrnb = callPackage ../all-pkgs/amrnb { };

amrwb = callPackage ../all-pkgs/amrwb { };

appdata-tools = callPackage ../all-pkgs/appdata-tools { };

appstream-glib = callPackage ../all-pkgs/appstream-glib { };

apr = callPackage ../all-pkgs/apr { };

apr-util = callPackage ../all-pkgs/apr-util { };

#ardour =  callPackage ../all-pkgs/ardour { };

argyllcms = callPackage ../all-pkgs/argyllcms { };

aria2 = callPackage ../all-pkgs/aria2 { };
aria = callPackageAlias "aria2" { };

arkive = callPackage ../all-pkgs/arkive { };

asciidoc = callPackage ../all-pkgs/asciidoc { };

asciinema = pkgs.goPackages.asciinema.bin // { outputs = [ "bin" ]; };

aspell = callPackage ../all-pkgs/aspell { };

atk = callPackage ../all-pkgs/atk { };

atkmm = callPackage ../all-pkgs/atkmm { };

attr = callPackage ../all-pkgs/attr { };

at-spi2-atk_2-20 = callPackage ../all-pkgs/at-spi2-atk {
  channel = "2.20";
};
at-spi2-atk = callPackageAlias "at-spi2-atk_2-20" { };

at-spi2-core = callPackage ../all-pkgs/at-spi2-core { };

audiofile = callPackage ../all-pkgs/audiofile { };

audit_full = callPackage ../all-pkgs/audit { };

audit_lib = callPackageAlias "audit_full" {
  prefix = "lib";
};

augeas = callPackage ../all-pkgs/augeas { };

autoconf = callPackage ../all-pkgs/autoconf { };

autoconf_21x = callPackageAlias "autoconf" {
  channel = "2.1x";
};

autogen = callPackage ../all-pkgs/autogen { };

automake = callPackage ../all-pkgs/automake { };

avahi = callPackage ../all-pkgs/avahi { };

babl = callPackage ../all-pkgs/babl { };

bash = callPackage ../all-pkgs/bash { };

bash-completion = callPackage ../all-pkgs/bash-completion { };

bc = callPackage ../all-pkgs/bc { };

bcache-tools = callPackage ../all-pkgs/bcache-tools { };

bcache-tools_dev = callPackageAlias "bcache-tools" {
  channel = "dev";
};

bison = callPackage ../all-pkgs/bison { };

bluez = callPackage ../all-pkgs/bluez { };

boehm-gc = callPackage ../all-pkgs/boehm-gc { };

boost155 = callPackage ../all-pkgs/boost/1.55.nix { };
boost161 = callPackage ../all-pkgs/boost/1.61.nix { };
boost = callPackageAlias "boost161" { };

brotli = callPackage ../all-pkgs/brotli { };

bs1770gain = callPackage ../all-pkgs/bs1770gain { };

btrfs-progs = callPackage ../all-pkgs/btrfs-progs { };

btsync = callPackage ../all-pkgs/btsync { };

bzip2 = callPackage ../all-pkgs/bzip2 { };

bzrtools = callPackage ../all-pkgs/bzrtools { };

cacert = callPackage ../all-pkgs/cacert { };

c-ares = callPackage ../all-pkgs/c-ares { };

cairo = callPackage ../all-pkgs/cairo { };

cairomm = callPackage ../all-pkgs/cairomm { };

caribou = callPackage ../all-pkgs/caribou { };

ccid = callPackage ../all-pkgs/ccid { };

cdparanoia = callPackage ../all-pkgs/cdparanoia { };

cdrtools = callPackage ../all-pkgs/cdrtools { };

# Only ever add ceph LTS releases
# The default channel should be the latest LTS
# Dev should always point to the latest versioned release
ceph_lib = pkgs.ceph.lib;
ceph = hiPrio (callPackage ../all-pkgs/ceph { });
ceph_0_94 = callPackage ../all-pkgs/ceph {
  channel = "0.94";
};
ceph_9 = callPackage ../all-pkgs/ceph {
  channel = "9";
};
ceph_10 = callPackage ../all-pkgs/ceph {
  channel = "10";
};
ceph_dev = callPackage ../all-pkgs/ceph {
  channel = "dev";
};
ceph_git = callPackage ../all-pkgs/ceph {
  channel = "git";
};

cgit = callPackage ../all-pkgs/cgit { };

cgmanager = callPackage ../all-pkgs/cgmanager { };

check = callPackage ../all-pkgs/check { };

chromaprint = callPackage ../all-pkgs/chromaprint { };

chromium = callPackage ../all-pkgs/chromium {
  channel = "stable";
};
chromium_beta = callPackageAlias "chromium" {
  channel = "beta";
};
chromium_dev = callPackageAlias "chromium" {
  channel = "dev";
};

cifs-utils = callPackage ../all-pkgs/cifs-utils { };

civetweb = callPackage ../all-pkgs/civetweb { };

cjdns = callPackage ../all-pkgs/cjdns { };

clang = wrapCC (callPackageAlias "llvm" { });

clutter = callPackage ../all-pkgs/clutter { };

clutter-gst_2 = callPackage ../all-pkgs/clutter-gst/2.x.nix { };
clutter-gst_3 = callPackage ../all-pkgs/clutter-gst/3.x.nix { };
clutter-gst = callPackageAlias "clutter-gst_3" { };

clutter-gtk = callPackage ../all-pkgs/clutter-gtk { };

cmake = callPackage ../all-pkgs/cmake { };

cogl = callPackage ../all-pkgs/cogl { };

colord = callPackage ../all-pkgs/colord { };

colord-gtk = callPackage ../all-pkgs/colord-gtk { };

conntrack-tools = callPackage ../all-pkgs/conntrack-tools { };

consul = pkgs.goPackages.consul.bin // { outputs = [ "bin" ]; };

consul-template = pkgs.goPackages.consul-template.bin // { outputs = [ "bin" ]; };

consul-ui = callPackage ../all-pkgs/consul-ui { };

coreutils = callPackage ../all-pkgs/coreutils { };

cpio = callPackage ../all-pkgs/cpio { };

cracklib = callPackage ../all-pkgs/cracklib { };

cryptodevHeaders = callPackage ../all-pkgs/cryptodev {
  onlyHeaders = true;
  kernel = null;
};

cryptopp = callPackage ../all-pkgs/crypto++ { };

cryptsetup = callPackage ../all-pkgs/cryptsetup { };

cuetools = callPackage ../all-pkgs/cuetools { };

cups = callPackage ../all-pkgs/cups { };

curl = callPackage ../all-pkgs/curl {
  suffix = "";
};

curl_full = callPackageAlias "curl" {
  suffix = "full";
};

cyrus-sasl = callPackage ../all-pkgs/cyrus-sasl { };

dash = callPackage ../all-pkgs/dash { };

db = callPackage ../all-pkgs/db { };
db_5 = callPackageAlias "db" {
  channel = "5";
};
db_6 = callPackageAlias "db" {
  channel = "6";
};

dbus = callPackage ../all-pkgs/dbus { };

dbus-glib = callPackage ../all-pkgs/dbus-glib { };

dconf = callPackage ../all-pkgs/dconf { };

dconf-editor = callPackage ../all-pkgs/dconf-editor { };

ddrescue = callPackage ../all-pkgs/ddrescue { };

dejagnu = callPackage ../all-pkgs/dejagnu { };

dialog = callPackage ../all-pkgs/dialog { };

ding-libs = callPackage ../all-pkgs/ding-libs { };

dmenu = callPackage ../all-pkgs/dmenu { };

devil_nox = callPackageAlias "devil" {
  xorg = null;
  mesa = null;
};
devil = callPackage ../all-pkgs/devil { };

dhcp = callPackage ../all-pkgs/dhcp { };

dhcpcd = callPackage ../all-pkgs/dhcpcd { };

diffutils = callPackage ../all-pkgs/diffutils { };

dmidecode = callPackage ../all-pkgs/dmidecode { };

dnscrypt-proxy = callPackage ../all-pkgs/dnscrypt-proxy { };

dnscrypt-wrapper = callPackage ../all-pkgs/dnscrypt-wrapper { };

dnsmasq = callPackage ../all-pkgs/dnsmasq { };

docbook-xsl = callPackage ../all-pkgs/docbook-xsl { };

docbook-xsl-ns = callPackageAlias "docbook-xsl" {
  type = "ns";
};

dosfstools = callPackage ../all-pkgs/dosfstools { };

dos2unix = callPackage ../all-pkgs/dos2unix { };

dotconf = callPackage ../all-pkgs/dotconf { };

double-conversion = callPackage ../all-pkgs/double-conversion { };

dpdk = callPackage ../all-pkgs/dpdk { };

#dropbox = callPackage ../all-pkgs/dropbox { };

dtc = callPackage ../all-pkgs/dtc { };

duplicity = pkgs.pythonPackages.duplicity;

e2fsprogs = callPackage ../all-pkgs/e2fsprogs { };

edac-utils = callPackage ../all-pkgs/edac-utils { };

efibootmgr = callPackage ../all-pkgs/efibootmgr { };

efivar = callPackage ../all-pkgs/efivar { };

eigen = callPackage ../all-pkgs/eigen { };

elfutils = callPackage ../all-pkgs/elfutils { };

emacs = callPackage ../all-pkgs/emacs { };

enca = callPackage ../all-pkgs/enca { };

enchant = callPackage ../all-pkgs/enchant { };

eog = callPackage ../all-pkgs/eog { };

erlang = callPackage ../all-pkgs/erlang { };

ethtool = callPackage ../all-pkgs/ethtool { };

evince = callPackage ../all-pkgs/evince { };

#evolution = callPackage ../all-pkgs/evolution { };

evolution-data-server = callPackage ../all-pkgs/evolution-data-server { };

exempi = callPackage ../all-pkgs/exempi { };

exiv2 = callPackage ../all-pkgs/exiv2 { };

expat = callPackage ../all-pkgs/expat { };

expect = callPackage ../all-pkgs/expect { };

f2fs-tools = callPackage ../all-pkgs/f2fs-tools { };

faac = callPackage ../all-pkgs/faac { };

fcgi = callPackage ../all-pkgs/fcgi { };

feh = callPackage ../all-pkgs/feh { };

ffmpeg_generic = overrides: callPackage ../all-pkgs/ffmpeg ({
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
  #libmfx = null;
  libmodplug = null;
  #libnut = null;
  #libnpp = null;
  libssh = null;
  libwebp = null; # ???
  libzimg = null;
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
ffmpeg_2 = pkgs.ffmpeg_generic {
  channel = "2";
};
ffmpeg_3 = pkgs.ffmpeg_generic {
  channel = "3";
};
ffmpeg_head = pkgs.ffmpeg_generic {
  channel = "9";
};
ffmpeg = callPackageAlias "ffmpeg_3" { };

fftw_double = callPackage ../all-pkgs/fftw {
  precision = "double";
};
fftw_long-double = callPackage ../all-pkgs/fftw {
  precision = "long-double";
};
fftw_quad = callPackage ../all-pkgs/fftw {
  precision = "quad-precision";
};
fftw_single = callPackage ../all-pkgs/fftw {
  precision = "single";
};

file = callPackage ../all-pkgs/file { };

file-roller = callPackage ../all-pkgs/file-roller { };

filezilla = callPackage ../all-pkgs/filezilla { };

findutils = callPackage ../all-pkgs/findutils { };

firefox = pkgs.firefox_wrapper pkgs.firefox-unwrapped { };
firefox-esr = pkgs.firefox_wrapper pkgs.firefox-esr-unwrapped { };
firefox-unwrapped = callPackage ../all-pkgs/firefox { };
firefox-esr-unwrapped = callPackage ../all-pkgs/firefox {
  channel = "esr";
};
firefox_wrapper = callPackage ../all-pkgs/firefox/wrapper.nix { };

#firefox-bin = callPackage ../applications/networking/browsers/firefox-bin { };

fish = callPackage ../all-pkgs/fish { };

flac = callPackage ../all-pkgs/flac { };

flex = callPackage ../all-pkgs/flex { };

fox = callPackage ../all-pkgs/fox { };

freeglut = callPackage ../all-pkgs/freeglut { };

freetype = callPackage ../all-pkgs/freetype { };

freetype2-infinality-ultimate =
  callPackage ../all-pkgs/freetype2-infinality-ultimate { };

fstrm = callPackage ../all-pkgs/fstrm { };

fuse = callPackage ../all-pkgs/fuse { };

game-music-emu = callPackage ../all-pkgs/game-music-emu { };

gawk = callPackage ../all-pkgs/gawk { };

gcab = callPackage ../all-pkgs/gcab { };

gconf = callPackage ../all-pkgs/gconf { };

gcr = callPackage ../all-pkgs/gcr { };

gdbm = callPackage ../all-pkgs/gdbm { };

gdk-pixbuf_wrapped = callPackage ../all-pkgs/gdk-pixbuf { };
gdk-pixbuf_unwrapped = callPackage ../all-pkgs/gdk-pixbuf/unwrapped.nix { };
gdk-pixbuf = callPackageAlias "gdk-pixbuf_wrapped" { };

gdm = callPackage ../all-pkgs/gdm { };

geoclue = callPackage ../all-pkgs/geoclue { };

gegl = callPackage ../all-pkgs/gegl { };

geocode-glib = callPackage ../all-pkgs/geocode-glib { };

geoip = callPackage ../all-pkgs/geoip { };

getopt = callPackage ../all-pkgs/getopt { };

gettext = callPackage ../all-pkgs/gettext { };

gexiv2 = callPackage ../all-pkgs/gexiv2 { };

gimp = callPackage ../all-pkgs/gimp { };

git = callPackage ../all-pkgs/git { };

gjs = callPackage ../all-pkgs/gjs { };

gksu = callPackage ../all-pkgs/gksu { };

glfw = callPackage ../all-pkgs/glfw { };

glib = callPackage ../all-pkgs/glib {
  channel = "2.48";
};

glibmm = callPackage ../all-pkgs/glibmm { };

glib-networking = callPackage ../all-pkgs/glib-networking { };

glusterfs = callPackage ../all-pkgs/glusterfs { };

gmp = callPackage ../all-pkgs/gmp { };

gnome-backgrounds = callPackage ../all-pkgs/gnome-backgrounds { };

gnome-bluetooth = callPackage ../all-pkgs/gnome-bluetooth { };

gnome-calculator = callPackage ../all-pkgs/gnome-calculator { };

gnome-clocks = callPackage ../all-pkgs/gnome-clocks { };

gnome-common = callPackage ../all-pkgs/gnome-common { };

gnome-control-center = callPackage ../all-pkgs/gnome-control-center { };

gnome-desktop = callPackage ../all-pkgs/gnome-desktop { };

gnome-documents = callPackage ../all-pkgs/gnome-documents { };

gnome-keyring = callPackage ../all-pkgs/gnome-keyring { };

gnome-menus = callPackage ../all-pkgs/gnome-menus { };

gnome-mpv = callPackage ../all-pkgs/gnome-mpv { };

gnome-online-accounts = callPackage ../all-pkgs/gnome-online-accounts { };

gnome-online-miners = callPackage ../all-pkgs/gnome-online-miners { };

gnome-screenshot = callPackage ../all-pkgs/gnome-screenshot { };

gnome-session = callPackage ../all-pkgs/gnome-session { };

gnome-settings-daemon = callPackage ../all-pkgs/gnome-settings-daemon { };

gnome-shell = callPackage ../all-pkgs/gnome-shell { };

gnome-shell-extensions = callPackage ../all-pkgs/gnome-shell-extensions { };

gnome-terminal = callPackage ../all-pkgs/gnome-terminal { };

gnome-themes-standard = callPackage ../all-pkgs/gnome-themes-standard { };

gnome-user-share = callPackage ../all-pkgs/gnome-user-share { };

gnome-wrapper = makeSetupHook {
  deps = [ makeWrapper ];
} ../build-support/setup-hooks/gnome-wrapper.sh;

gnu-efi = callPackage ../all-pkgs/gnu-efi { };

gnugrep = callPackage ../all-pkgs/gnugrep { };

gnum4 = callPackage ../all-pkgs/gnum4 { };

gnumake = callPackage ../all-pkgs/gnumake { };

gnonlin = callPackage ../all-pkgs/gnonlin { };

gnupatch = callPackage ../all-pkgs/gnupatch { };

gnupg_2_0 = callPackageAlias "gnupg" {
  channel = "2.0";
};

gnupg_2_1 = callPackageAlias "gnupg" {
  channel = "2.1";
};

gnupg = callPackage ../all-pkgs/gnupg { };

gnused = callPackage ../all-pkgs/gnused { };

gnutar = callPackage ../all-pkgs/gnutar { };

gnutls = callPackage ../all-pkgs/gnutls { };

go = callPackage ../all-pkgs/go { };

go_1_6 = callPackageAlias "go" {
  channel = "1.6";
};

go16Packages = callPackage ./go-packages.nix {
  go = callPackageAlias "go_1_6" { };
  buildGoPackage = callPackage ../all-pkgs/build-go-package {
    go = callPackageAlias "go_1_6" { };
    govers = (callPackageAlias "go16Packages" { }).govers.bin;
  };
  overrides = (config.goPackageOverrides or (p: { })) pkgs;
};
goPackages = callPackageAlias "go16Packages" { };

gobject-introspection = callPackage ../all-pkgs/gobject-introspection { };

google-gflags = callPackage ../all-pkgs/google-gflags { };

gperf = callPackage ../all-pkgs/gperf { };

gperftools = callPackage ../all-pkgs/gperftools { };

gpm = callPackage ../all-pkgs/gpm-ncurses { };

gpsd = callPackage ../all-pkgs/gpsd { };

gptfdisk = callPackage ../all-pkgs/gptfdisk { };

grafana = pkgs.goPackages.grafana.bin // { outputs = [ "bin" ]; };

granite = callPackage ../all-pkgs/granite { };

graphite2 = callPackage ../all-pkgs/graphite2 { };

graphviz = callPackage ../all-pkgs/graphviz { };

grilo = callPackage ../all-pkgs/grilo { };

grilo-plugins = callPackage ../all-pkgs/grilo-plugins { };

groff = callPackage ../all-pkgs/groff { };

gsettings-desktop-schemas = callPackage ../all-pkgs/gsettings-desktop-schemas { };

gsm = callPackage ../all-pkgs/gsm { };

gsound = callPackage ../all-pkgs/gsound { };

gssdp = callPackage ../all-pkgs/gssdp { };

gst-libav = callPackage ../all-pkgs/gst-libav { };

gst-plugins-bad = callPackage ../all-pkgs/gst-plugins-bad { };

gst-plugins-base = callPackage ../all-pkgs/gst-plugins-base { };

gst-plugins-good = callPackage ../all-pkgs/gst-plugins-good { };

gst-plugins-ugly = callPackage ../all-pkgs/gst-plugins-ugly { };

gst-validate = callPackage ../all-pkgs/gst-validate { };

gstreamer = callPackage ../all-pkgs/gstreamer { };

gstreamer-editing-services = callPackage ../all-pkgs/gstreamer-editing-services { };

gstreamer-vaapi = callPackage ../all-pkgs/gstreamer-vaapi { };

gtk-doc = callPackage ../all-pkgs/gtk-doc { };

gtk_2 = callPackage ../all-pkgs/gtk/2.x.nix { };
gtk2 = callPackageAlias "gtk_2" { };
gtk_3 = callPackage ../all-pkgs/gtk/3.x.nix { };
gtk3 = callPackageAlias "gtk_3" { };

gtkhtml = callPackage ../all-pkgs/gtkhtml { };

gtkimageview = callPackage ../all-pkgs/gtkimageview { };

gtkmm_2 = callPackage ../all-pkgs/gtkmm/2.x.nix { };
gtkmm_3 = callPackage ../all-pkgs/gtkmm/3.x.nix { };

gtksourceview = callPackage ../all-pkgs/gtksourceview { };

gtkspell_2 = callPackage ../all-pkgs/gtkspell/2.x.nix { };
gtkspell_3 = callPackage ../all-pkgs/gtkspell/3.x.nix { };
gtkspell = callPackageAlias "gtkspell_3" { };

guile = callPackage ../all-pkgs/guile { };

guitarix = callPackage ../all-pkgs/guitarix {
  fftw = pkgs.fftw_single;
};

gupnp = callPackage ../all-pkgs/gupnp { };

gupnp-av = callPackage ../all-pkgs/gupnp-av { };

gupnp-igd = callPackage ../all-pkgs/gupnp-igd { };

gvfs = callPackage ../all-pkgs/gvfs { };

gx = pkgs.goPackages.gx.bin // { outputs = [ "bin" ]; };

gzip = callPackage ../all-pkgs/gzip { };

hadoop = callPackage ../all-pkgs/hadoop { };

harfbuzz = callPackage ../all-pkgs/harfbuzz { };

hdparm = callPackage ../all-pkgs/hdparm { };

help2man = callPackage ../all-pkgs/help2man { };

hexchat = callPackage ../all-pkgs/hexchat { };

hicolor-icon-theme = callPackage ../all-pkgs/hicolor-icon-theme { };

highlight = callPackage ../all-pkgs/highlight { };

hiredis = callPackage ../all-pkgs/hiredis { };

htop = callPackage ../all-pkgs/htop { };

http-parser = callPackage ../all-pkgs/http-parser { };

hunspell = callPackage ../all-pkgs/hunspell { };

hwdata = callPackage ../all-pkgs/hwdata { };

iana-etc = callPackage ../all-pkgs/iana-etc { };

iasl = callPackage ../all-pkgs/iasl { };

ibus = callPackage ../all-pkgs/ibus { };

ice = callPackage ../all-pkgs/ice { };

icu = callPackage ../all-pkgs/icu { };

id3lib = callPackage ../all-pkgs/id3lib { };

id3v2 = callPackage ../all-pkgs/id3v2 { };

imagemagick = callPackage ../all-pkgs/imagemagick { };

iniparser = callPackage ../all-pkgs/iniparser { };

inkscape = callPackage ../all-pkgs/inkscape { };

intel-microcode = callPackage ../all-pkgs/intel-microcode { };

intltool = callPackage ../all-pkgs/intltool { };

iotop = pkgs.pythonPackages.iotop;

iperf = callPackage ../all-pkgs/iperf { };

iperf_2 = callPackageAlias "iperf" {
  channel = "2";
};

iperf_3 = callPackageAlias "iperf" {
  channel = "3";
};

ipfs = pkgs.goPackages.ipfs.bin // { outputs = [ "bin" ]; };

ipfs-hasher = callPackage ../all-pkgs/ipfs-hasher { };

ipset = callPackage ../all-pkgs/ipset { };

iproute = callPackage ../all-pkgs/iproute { };

iptables = callPackage ../all-pkgs/iptables { };

ipmitool = callPackage ../all-pkgs/ipmitool { };

iputils = callPackage ../all-pkgs/iputils { };

isl = callPackage ../all-pkgs/isl { };
isl_0_14 = callPackage ../all-pkgs/isl { channel = "0.14"; };

iso-codes = callPackage ../all-pkgs/iso-codes { };

itstool = callPackage ../all-pkgs/itstool { };

iw = callPackage ../all-pkgs/iw { };

jam = callPackage ../all-pkgs/jam { };

jansson = callPackage ../all-pkgs/jansson { };

jemalloc = callPackage ../all-pkgs/jemalloc { };

jq = callPackage ../all-pkgs/jq { };

jshon = callPackage ../all-pkgs/jshon { };

json-c = callPackage ../all-pkgs/json-c { };

jsoncpp = callPackage ../all-pkgs/jsoncpp { };

json-glib = callPackage ../all-pkgs/json-glib { };

judy = callPackage ../all-pkgs/judy { };

kbd = callPackage ../all-pkgs/kbd { };

kea = callPackage ../all-pkgs/kea { };

keepalived = callPackage ../all-pkgs/keepalived { };

keepassx = callPackage ../all-pkgs/keepassx { };

kerberos = callPackageAlias "krb5_lib" { };

kexec-tools = callPackage ../all-pkgs/kexec-tools { };

keyutils = callPackage ../all-pkgs/keyutils { };

kid3 = callPackage ../all-pkgs/kid3 { };

kmod = callPackage ../all-pkgs/kmod { };

kmscon = callPackage ../all-pkgs/kmscon { };

knot = callPackage ../all-pkgs/knot { };

krb5_full = callPackage ../all-pkgs/krb5 { };

krb5_lib = callPackageAlias "krb5_full" {
  type = "lib";
};

#kubernetes = callPackage ../all-pkgs/kubernetes { };

kyotocabinet = callPackage ../all-pkgs/kyotocabinet { };

lame = callPackage ../all-pkgs/lame { };

ldb = callPackage ../all-pkgs/ldb { };

lego = pkgs.goPackages.lego.bin // { outputs = [ "bin" ]; };

lensfun = callPackage ../all-pkgs/lensfun { };

leptonica = callPackage ../all-pkgs/leptonica { };

leveldb = callPackage ../all-pkgs/leveldb { };

letskencrypt = callPackage ../all-pkgs/letskencrypt { };

lftp = callPackage ../all-pkgs/lftp { };

lib-bash = callPackage ../all-pkgs/lib-bash { };

libaccounts-glib = callPackage ../all-pkgs/libaccounts-glib { };

libaio = callPackage ../all-pkgs/libaio { };

libarchive = callPackage ../all-pkgs/libarchive { };

libasr = callPackage ../all-pkgs/libasr { };

libass = callPackage ../all-pkgs/libass { };

libassuan = callPackage ../all-pkgs/libassuan { };

libatasmart = callPackage ../all-pkgs/libatasmart { };

libatomic_ops = callPackage ../all-pkgs/libatomic_ops { };

libavc1394 = callPackage ../all-pkgs/libavc1394 { };

libdc1394 = callPackage ../all-pkgs/libdc1394 { };

libbluray = callPackage ../all-pkgs/libbluray { };

libbsd = callPackage ../all-pkgs/libbsd { };

libburn = callPackage ../all-pkgs/libburn { };

libcacard = callPackage ../all-pkgs/libcacard { };

libcanberra = callPackage ../all-pkgs/libcanberra { };

libcap-ng = callPackage ../all-pkgs/libcap-ng { };

libclc = callPackage ../all-pkgs/libclc { };

libcroco = callPackage ../all-pkgs/libcroco { };

libcue = callPackage ../all-pkgs/libcue { };

libdrm = callPackage ../all-pkgs/libdrm { };

libebml = callPackage ../all-pkgs/libebml { };

libedit = callPackage ../all-pkgs/libedit { };

libelf = callPackage ../all-pkgs/libelf { };

libepoxy = callPackage ../all-pkgs/libepoxy { };

libev = callPackage ../all-pkgs/libev { };

libevdev = callPackage ../all-pkgs/libevdev { };

libevent = callPackage ../all-pkgs/libevent { };

libfaketime = callPackage ../all-pkgs/libfaketime { };

libffi = callPackage ../all-pkgs/libffi { };

libfilezilla = callPackage ../all-pkgs/libfilezilla { };

libfpx = callPackage ../all-pkgs/libfpx { };

libgcrypt = callPackage ../all-pkgs/libgcrypt { };

libgd = callPackage ../all-pkgs/libgd { };

libgdata = callPackage ../all-pkgs/libgdata { };

libgee = callPackage ../all-pkgs/libgee { };

libgfbgraph = callPackage ../all-pkgs/libgfbgraph { };

libgksu = callPackage ../all-pkgs/libgksu { };

libglade = callPackage ../all-pkgs/libglade { };

libglvnd = callPackage ../all-pkgs/libglvnd { };

libgnome-keyring = callPackage ../all-pkgs/libgnome-keyring { };

libgnomekbd = callPackage ../all-pkgs/libgnomekbd { };

libgpg-error = callPackage ../all-pkgs/libgpg-error { };

libgphoto2 = callPackage ../all-pkgs/libgphoto2 { };

libgpod = callPackage ../all-pkgs/libgpod {
  inherit (pkgs.pythonPackages) mutagen;
};

libgsf = callPackage ../all-pkgs/libgsf { };

libgudev = callPackage ../all-pkgs/libgudev { };

libgusb = callPackage ../all-pkgs/libgusb { };

libgweather = callPackage ../all-pkgs/libgweather { };

libgxps = callPackage ../all-pkgs/libgxps { };

libibverbs = callPackage ../all-pkgs/libibverbs { };

libical = callPackage ../all-pkgs/libical { };

libidl = callPackage ../all-pkgs/libidl { };

libidn = callPackage ../all-pkgs/libidn { };

libinput = callPackage ../all-pkgs/libinput { };

libisoburn = callPackage ../all-pkgs/libisoburn { };

libisofs = callPackage ../all-pkgs/libisofs { };

libjpeg_original = callPackage ../all-pkgs/libjpeg { };
libjpeg-turbo_1-4 = callPackage ../all-pkgs/libjpeg-turbo {
  channel = "1.4";
};
libjpeg-turbo_1-5 = callPackage ../all-pkgs/libjpeg-turbo {
  channel = "1.5";
};
libjpeg-turbo = callPackageAlias "libjpeg-turbo_1-5" { };
libjpeg = callPackageAlias "libjpeg-turbo" { };

libksba = callPackage ../all-pkgs/libksba { };

liblogging = callPackage ../all-pkgs/liblogging { };

libmatroska = callPackage ../all-pkgs/libmatroska { };

libmbim = callPackage ../all-pkgs/libmbim { };

libmcrypt = callPackage ../all-pkgs/libmcrypt { };

libmediaart = callPackage ../all-pkgs/libmediaart {
  qt5 = null;
};

libmhash = callPackage ../all-pkgs/libmhash { };

libmicrohttpd = callPackage ../all-pkgs/libmicrohttpd { };

libmnl = callPackage ../all-pkgs/libmnl { };

libmodplug = callPackage ../all-pkgs/libmodplug { };

libmpc = callPackage ../all-pkgs/libmpc { };

libmpdclient = callPackage ../all-pkgs/libmpdclient { };

libmpeg2 = callPackage ../all-pkgs/libmpeg2 {
  libSDL = null;
  xorg = null;
};

libmsgpack = callPackage ../all-pkgs/libmsgpack { };

libmtp = callPackage ../all-pkgs/libmtp { };

libmusicbrainz = callPackage ../all-pkgs/libmusicbrainz { };

libmypaint = callPackage ../all-pkgs/libmypaint { };

libnetfilter_conntrack = callPackage ../all-pkgs/libnetfilter_conntrack { };

libnetfilter_cthelper = callPackage ../all-pkgs/libnetfilter_cthelper { };

libnetfilter_cttimeout = callPackage ../all-pkgs/libnetfilter_cttimeout { };

libnetfilter_queue = callPackage ../all-pkgs/libnetfilter_queue { };

libnfnetlink = callPackage ../all-pkgs/libnfnetlink { };

libnfsidmap = callPackage ../all-pkgs/libnfsidmap { };

libnftnl = callPackage ../all-pkgs/libnftnl { };

libnih = callPackage ../all-pkgs/libnih { };

libnl = callPackage ../all-pkgs/libnl { };

libogg = callPackage ../all-pkgs/libogg { };

libomxil-bellagio = callPackage ../all-pkgs/libomxil-bellagio { };

libosinfo = callPackage ../all-pkgs/libosinfo { };

libossp-uuid = callPackage ../all-pkgs/libossp-uuid { };

libpcap = callPackage ../all-pkgs/libpcap { };

libpeas = callPackage ../all-pkgs/libpeas { };

libpipeline = callPackage ../all-pkgs/libpipeline { };

libpng = callPackage ../all-pkgs/libpng { };

libproxy = callPackage ../all-pkgs/libproxy { };

libqmi = callPackage ../all-pkgs/libqmi { };

libraw = callPackage ../all-pkgs/libraw { };

libraw1394 = callPackage ../all-pkgs/libraw1394 { };

librelp = callPackage ../all-pkgs/librelp { };

libressl = callPackage ../all-pkgs/libressl { };

librdmacm = callPackage ../all-pkgs/librdmacm { };

librsvg = callPackage ../all-pkgs/librsvg { };

librsync = callPackage ../all-pkgs/librsync { };

libs3 = callPackage ../all-pkgs/libs3 { };

libsamplerate = callPackage ../all-pkgs/libsamplerate { };

libseccomp = callPackage ../all-pkgs/libseccomp { };

libsecret = callPackage ../all-pkgs/libsecret { };

libselinux = callPackage ../all-pkgs/libselinux { };

libsepol = callPackage ../all-pkgs/libsepol { };

libshout = callPackage ../all-pkgs/libshout { };

libsigcxx = callPackage ../all-pkgs/libsigcxx { };

libsigsegv = callPackage ../all-pkgs/libsigsegv { };

libsmbios = callPackage ../all-pkgs/libsmbios { };

libsndfile = callPackage ../all-pkgs/libsndfile { };

libsodium = callPackage ../all-pkgs/libsodium { };

libsoup = callPackage ../all-pkgs/libsoup { };

libspectre = callPackage ../all-pkgs/libspectre { };

libssh = callPackage ../all-pkgs/libssh { };

libssh2 = callPackage ../all-pkgs/libssh2 { };

libtasn1 = callPackage ../all-pkgs/libtasn1 { };

libtheora = callPackage ../all-pkgs/libtheora { };

libtirpc = callPackage ../all-pkgs/libtirpc { };

libtool = callPackage ../all-pkgs/libtool { };

libtorrent = callPackage ../all-pkgs/libtorrent { };

libtorrent-rasterbar_1-0 = callPackage ../all-pkgs/libtorrent-rasterbar {
  channel = "1.0";
};
libtorrent-rasterbar_1-1 = callPackage ../all-pkgs/libtorrent-rasterbar {
  channel = "1.1";
};
libtorrent-rasterbar = callPackageAlias "libtorrent-rasterbar_1-1" { };

libtsm = callPackage ../all-pkgs/libtsm { };

libunique_1 = callPackage ../all-pkgs/libunique/1.x.nix { };
libunique_3 = callPackage ../all-pkgs/libunique/3.x.nix { };
libunique = callPackageAlias "libunique_3" { };

libunwind = callPackage ../all-pkgs/libunwind { };

liburcu = callPackage ../all-pkgs/liburcu { };

libusb-compat = callPackage ../all-pkgs/libusb-compat { };

libusb_0 = callPackageAlias "libusb-compat" { };
libusb_1 = callPackage ../all-pkgs/libusb { };
libusb = callPackageAlias "libusb_1" { };

libusbmuxd = callPackage ../all-pkgs/libusbmuxd { };

libutempter = callPackage ../all-pkgs/libutempter { };

libuv = callPackage ../all-pkgs/libuv { };

libva = callPackage ../all-pkgs/libva { };

libva-vdpau-driver = callPackage ../all-pkgs/libva-vdpau-driver { };

libvdpau = callPackage ../all-pkgs/libvdpau { };

libvdpau-va-gl = callPackage ../all-pkgs/libvdpau-va-gl { };

libverto = callPackage ../all-pkgs/libverto { };

libvorbis = callPackage ../all-pkgs/libvorbis { };

libvpx = callPackage ../all-pkgs/libvpx { };
#libvpx_HEAD = callPackage ../development/libraries/libvpx/git.nix { };

libwacom = callPackage ../all-pkgs/libwacom { };

libwebp = callPackage ../all-pkgs/libwebp { };

libwps = callPackage ../all-pkgs/libwps { };

libxkbcommon = callPackage ../all-pkgs/libxkbcommon { };

libxklavier = callPackage ../all-pkgs/libxklavier { };

libxml2 = callPackage ../all-pkgs/libxml2 { };

libxslt = callPackage ../all-pkgs/libxslt { };

libyaml = callPackage ../all-pkgs/libyaml { };

libzapojit = callPackage ../all-pkgs/libzapojit { };

libzip = callPackage ../all-pkgs/libzip { };

lightdm = callPackage ../all-pkgs/lightdm { };

lightdm-gtk-greeter = callPackage ../all-pkgs/lightdm-gtk-greeter { };

lilv = callPackage ../all-pkgs/lilv { };

linux-headers = callPackage ../all-pkgs/linux-headers { };

linux-headers_4_6 = callPackage ../all-pkgs/linux-headers {
  channel = "4.6";
};

lirc = callPackage ../all-pkgs/lirc { };

live555 = callPackage ../all-pkgs/live555 { };

llvm = callPackage ../all-pkgs/llvm { };

lmdb = callPackage ../all-pkgs/lmdb { };

lm-sensors = callPackage ../all-pkgs/lm-sensors { };

lrdf = callPackage ../all-pkgs/lrdf { };

lsof = callPackage ../all-pkgs/lsof { };

luajit = callPackage ../all-pkgs/luajit { };

lv2 = callPackage ../all-pkgs/lv2 { };

lvm2 = callPackage ../all-pkgs/lvm2 { };

lxc = callPackage ../all-pkgs/lxc { };

lxd = pkgs.goPackages.lxd.bin // { outputs = [ "bin" ]; };

lz4 = callPackage ../all-pkgs/lz4 { };

lzip = callPackage ../all-pkgs/lzip { };

lzo = callPackage ../all-pkgs/lzo { };

m4 = callPackageAlias "gnum4" { };

mac = callPackage ../all-pkgs/mac { };

man-db = callPackage ../all-pkgs/man-db { };

man-pages = callPackage ../all-pkgs/man-pages { };

mercurial = callPackage ../all-pkgs/mercurial { };

mesa_glu =  callPackage ../all-pkgs/mesa-glu { };
mesa_noglu = callPackage ../all-pkgs/mesa {
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

#mesos = callPackage ../all-pkgs/mesos {
#  inherit (pythonPackages) python boto setuptools wrapPython;
#  pythonProtobuf = pythonPackages.protobuf2_5;
 # perf = linuxPackages.perf;
#};

mg = callPackage ../all-pkgs/mg { };

mime-types = callPackage ../all-pkgs/mime-types { };

minipro = callPackage ../all-pkgs/minipro { };

minisign = callPackage ../all-pkgs/minisign { };

mixxx = callPackage ../all-pkgs/mixxx { };

mkvtoolnix = callPackage ../all-pkgs/mkvtoolnix { };

modemmanager = callPackage ../all-pkgs/modemmanager { };

mongodb = callPackage ../all-pkgs/mongodb { };

mongodb-tools = pkgs.goPackages.mongo-tools.bin // { outputs = [ "bin" ]; };

mosh = callPackage ../all-pkgs/mosh { };

motif = callPackage ../all-pkgs/motif { };

mp4v2 = callPackage ../all-pkgs/mp4v2 { };

mpd = callPackage ../all-pkgs/mpd { };

mpdris2 = callPackage ../all-pkgs/mpdris2 { };

mpfr = callPackage ../all-pkgs/mpfr { };

mpv = callPackage ../all-pkgs/mpv { };

ms-sys = callPackage ../all-pkgs/ms-sys { };

mtdev = callPackage ../all-pkgs/mtdev { };

mtr = callPackage ../all-pkgs/mtr { };

mtools = callPackage ../all-pkgs/mtools { };

inherit (callPackages ../all-pkgs/mumble {
  jackSupport = config.jack or false;
  speechdSupport = config.mumble.speechdSupport or false;
  pulseSupport = config.pulseaudio or false;
  iceSupport = config.murmur.iceSupport or true;
})
  mumble
  mumble_git
  murmur
  murmur_git;

musepack = callPackage ../all-pkgs/musepack { };

musl = callPackage ../all-pkgs/musl { };

mutter = callPackage ../all-pkgs/mutter { };

mxml = callPackage ../all-pkgs/mxml { };

nano = callPackage ../all-pkgs/nano { };

nasm = callPackage ../all-pkgs/nasm { };

nautilus = callPackage ../all-pkgs/nautilus { };

ncdc = callPackage ../all-pkgs/ncdc { };

#ncmpc = callPackage ../all-pkgs/ncmpc { };

ncmpcpp = callPackage ../all-pkgs/ncmpcpp { };

ncurses = callPackage ../all-pkgs/gpm-ncurses { };

net-snmp = callPackage ../all-pkgs/net-snmp { };

net-tools = callPackage ../all-pkgs/net-tools { };

nettle = callPackage ../all-pkgs/nettle { };

networkmanager = callPackage ../all-pkgs/networkmanager { };

networkmanager-openvpn = callPackage ../all-pkgs/networkmanager-openvpn { };

networkmanager-pptp = callPackage ../all-pkgs/networkmanager-pptp { };

networkmanager-l2tp = callPackage ../all-pkgs/networkmanager-l2tp { };

networkmanager-vpnc = callPackage ../all-pkgs/networkmanager-vpnc { };

networkmanager-openconnect = callPackage ../all-pkgs/networkmanager-openconnect { };

networkmanager-applet = callPackage ../all-pkgs/networkmanager-applet { };

nfs-utils = callPackage ../all-pkgs/nfs-utils { };

nftables = callPackage ../all-pkgs/nftables { };

nghttp2_full = callPackage ../all-pkgs/nghttp2 { };

nghttp2_lib = callPackageAlias "nghttp2_full" {
  prefix = "lib";
};

nginx = callPackage ../all-pkgs/nginx { };

nginx_unstable = callPackageAlias "nginx" {
  channel = "unstable";
};

ninja = callPackage ../all-pkgs/ninja { };

nix = callPackage ../all-pkgs/nix { };

nix_unstable = callPackageAlias "nix" {
  channel = "unstable";
};

nmap = callPackage ../all-pkgs/nmap { };

nodejs = callPackage ../all-pkgs/nodejs { };

noise = callPackage ../all-pkgs/noise { };

nomad = pkgs.goPackages.nomad.bin // { outputs = [ "bin" ]; };

npth = callPackage ../all-pkgs/npth { };

nspr = callPackage ../all-pkgs/nspr { };

nss = callPackage ../all-pkgs/nss { };

nss_wrapper = callPackage ../all-pkgs/nss_wrapper { };

ntfs-3g = callPackage ../all-pkgs/ntfs-3g { };

ntp = callPackage ../all-pkgs/ntp { };

numactl = callPackage ../all-pkgs/numactl { };

nvidia-cuda-toolkit_7-5 = callPackage ../all-pkgs/nvidia-cuda-toolkit {
  channel = "7.5";
};
#nvidia-cuda-toolkit_8-0 = callPackage ../all-pkgs/nvidia-cuda-toolkit {
#  channel = "8.0";
#};
nvidia-cuda-toolkit = callPackageAlias "nvidia-cuda-toolkit_7-5" { };

nvidia-video-codec-sdk = callPackage ../all-pkgs/nvidia-video-codec-sdk { };

obexftp = callPackage ../all-pkgs/obexftp { };

oniguruma = callPackage ../all-pkgs/oniguruma { };

openldap = callPackage ../all-pkgs/openldap { };

openntpd = callPackage ../all-pkgs/openntpd { };

openobex = callPackage ../all-pkgs/openobex { };

opensmtpd = callPackage ../all-pkgs/opensmtpd { };

opensmtpd-extras = callPackage ../all-pkgs/opensmtpd-extras { };

openssh = callPackage ../all-pkgs/openssh { };

openssl = callPackage ../all-pkgs/openssl { };

openvpn = callPackage ../all-pkgs/openvpn { };

opus = callPackage ../all-pkgs/opus { };

opus-tools = callPackage ../all-pkgs/opus-tools { };

opusfile = callPackage ../all-pkgs/opusfile { };

orbit2 = callPackage ../all-pkgs/orbit2 { };

orc = callPackage ../all-pkgs/orc { };

p7zip = callPackage ../all-pkgs/p7zip { };

pam = callPackage ../all-pkgs/pam { };

pango = callPackage ../all-pkgs/pango { };

pangomm = callPackage ../all-pkgs/pangomm { };

pangox-compat = callPackage ../all-pkgs/pangox-compat { };

parallel = callPackage ../all-pkgs/parallel { };

patchelf = callPackage ../all-pkgs/patchelf { };

patchutils = callPackage ../all-pkgs/patchutils { };

pavucontrol = callPackage ../all-pkgs/pavucontrol { };

pciutils = callPackage ../all-pkgs/pciutils { };

pcre = callPackage ../all-pkgs/pcre { };

pcre2 = callPackage ../all-pkgs/pcre2 { };

pcsc-lite_full = callPackage ../all-pkgs/pcsc-lite {
  libOnly = false;
};

pcsc-lite_lib = callPackageAlias "pcsc-lite_full" {
  libOnly = true;
};

perl = callPackage ../all-pkgs/perl { };

pgbouncer = callPackage ../all-pkgs/pgbouncer { };

pinentry = callPackage ../all-pkgs/pinentry { };

pkcs11-helper = callPackage ../all-pkgs/pkcs11-helper { };

pkgconf = callPackage ../all-pkgs/pkgconf { };
pkg-config = callPackage ../all-pkgs/pkgconfig { };
pkgconfig = callPackageAlias "pkgconf" { };

plymouth = callPackage ../all-pkgs/plymouth { };

pngcrush = callPackage ../all-pkgs/pngcrush { };

polkit = callPackage ../all-pkgs/polkit { };

poppler_qt = callPackageAlias "poppler" {
  suffix = "qt5";
  qt5 = pkgs.qt5;
};
poppler_utils = callPackageAlias "poppler" {
  suffix = "utils";
  utils = true;
};
poppler = callPackage ../all-pkgs/poppler {
  qt5 = null;
};

postgresql = callPackage ../all-pkgs/postgresql { };
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

potrace = callPackage ../all-pkgs/potrace { };

powertop = callPackage ../all-pkgs/powertop { };

procps-ng = callPackage ../all-pkgs/procps-ng { };

procps = callPackageAlias "procps-ng" { };

prometheus = pkgs.goPackages.prometheus.bin // { outputs = [ "bin" ]; };

protobuf-c = callPackage ../all-pkgs/protobuf-c { };

protobuf-cpp = callPackage ../all-pkgs/protobuf-cpp { };

psmisc = callPackage ../all-pkgs/psmisc { };

pth = callPackage ../all-pkgs/pth { };

pugixml = callPackage ../all-pkgs/pugixml { };

pulseaudio_full = callPackage ../all-pkgs/pulseaudio { };

pulseaudio_lib = callPackageAlias "pulseaudio_full" {
  prefix = "lib";
};

python27 = callPackage ../all-pkgs/python {
  channel = "2.7";
  self = callPackageAlias "python27" { };
};
python33 = callPackage ../all-pkgs/python {
  channel = "3.3";
  self = callPackageAlias "python33" { };
};
python34 = callPackage ../all-pkgs/python {
  channel = "3.4";
  self = callPackageAlias "python34" { };
};
python35 = hiPrio (callPackage ../all-pkgs/python {
  channel = "3.5";
  self = callPackageAlias "python35" { };
});
python36 = callPackage ../all-pkgs/python {
  channel = "3.6";
  self = callPackageAlias "python36" { };
};
#pypy = callPackage ../all-pkgs/pypy {
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

qbittorrent = callPackage ../all-pkgs/qbittorrent { };

qca = callPackage ../all-pkgs/qca { };

qjackctl = callPackage ../all-pkgs/qjackctl { };

qrencode = callPackage ../all-pkgs/qrencode { };

qt4 = callPackage ../all-pkgs/qt/4 { };

qt5 = callPackage ../all-pkgs/qt/5.x.nix { };

quassel = callPackage ../all-pkgs/quassel rec {
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

radvd = callPackage ../all-pkgs/radvd { };

rapidjson = callPackage ../all-pkgs/rapidjson { };

raptor2 = callPackage ../all-pkgs/raptor2 { };

re2c = callPackage ../all-pkgs/re2c { };

readline = callPackage ../all-pkgs/readline { };

recode = callPackage ../all-pkgs/recode { };

redis = callPackage ../all-pkgs/redis { };

resolv_wrapper = callPackage ../all-pkgs/resolv_wrapper { };

rest = callPackage ../all-pkgs/rest { };

rfkill = callPackage ../all-pkgs/rfkill { };

rocksdb = callPackage ../all-pkgs/rocksdb { };

rtkit = callPackage ../all-pkgs/rtkit { };

rtmpdump = callPackage ../all-pkgs/rtmpdump { };

rtorrent = callPackage ../all-pkgs/rtorrent { };

ruby = callPackage ../all-pkgs/ruby { };

rustc = hiPrio (callPackage ../all-pkgs/rustc { });

rustc_bootstrap = lowPrio (callPackage ../all-pkgs/rustc/bootstrap.nix { });

#rustc_beta = callPackageAlias "rustc" {
#  channel = "beta";
#};

#rustc_dev = callPackageAlias "rustc" {
#  channel = "dev";
#};

sakura = callPackage ../all-pkgs/sakura { };

samba_full = callPackage ../all-pkgs/samba { };

samba_client = callPackageAlias "samba_full" {
  type = "client";
};

scons = pkgs.pythonPackages.scons;

screen = callPackage ../all-pkgs/screen { };

scrot = callPackage ../all-pkgs/scrot { };

# TODO SDL is a clusterfuck that needs to be fixed / renamed
SDL = callPackage ../all-pkgs/SDL_1 { };

SDL_image = callPackage ../all-pkgs/SDL_1_image { };

SDL_2 = callPackage ../all-pkgs/SDL { };

SDL_2_image = callPackage ../all-pkgs/SDL_image { };

sdparm = callPackage ../all-pkgs/sdparm { };

seabios = callPackage ../all-pkgs/seabios { };

seahorse = callPackage ../all-pkgs/seahorse { };

serd = callPackage ../all-pkgs/serd { };

serf = callPackage ../all-pkgs/serf { };

shared_mime_info = callPackage ../all-pkgs/shared-mime-info { };

sharutils = callPackage ../all-pkgs/sharutils { };

smartmontools = callPackage ../all-pkgs/smartmontools { };

snappy = callPackage ../all-pkgs/snappy { };

shntool = callPackage ../all-pkgs/shntool { };

sl = callPackage ../all-pkgs/sl { };

slock = callPackage ../all-pkgs/slock { };

socket_wrapper = callPackage ../all-pkgs/socket_wrapper { };

sord = callPackage ../all-pkgs/sord { };

sox = callPackage ../all-pkgs/sox {
  amrnb = null;
  amrwb = null;
};

soxr = callPackage ../all-pkgs/soxr { };

spectrwm = callPackage ../all-pkgs/spectrwm { };

spice = callPackage ../all-pkgs/spice { };

spice-protocol = callPackage ../all-pkgs/spice-protocol { };

spidermonkey = callPackage ../all-pkgs/spidermonkey { };

spidermonkey_45 = callPackageAlias "spidermonkey" {
  channel = "45";
};

spidermonkey_24 = callPackageAlias "spidermonkey" {
  channel = "24";
};

spidermonkey_17 = callPackageAlias "spidermonkey" {
  channel = "17";
};

split2flac = callPackage ../all-pkgs/split2flac { };

sqlheavy = callPackage ../all-pkgs/sqlheavy { };

sqlite = callPackage ../all-pkgs/sqlite { };

squashfs-tools = callPackage ../all-pkgs/squashfs-tools { };

sratom = callPackage ../all-pkgs/sratom { };

sssd = callPackage ../all-pkgs/sssd { };

st = callPackage ../all-pkgs/st {
  config = config.st.config or null;
  configFile = config.st.configFile or null;
};

#steamPackages = callPackage ../all-pkgs/steam { };
#steam = steamPackages.steam-chrootenv.override {
#  # DEPRECATED
#  withJava = config.steam.java or false;
#  withPrimus = config.steam.primus or false;
#};

strace = callPackage ../all-pkgs/strace { };

sublime-text = callPackage ../all-pkgs/sublime-text { };

subversion = callPackage ../all-pkgs/subversion { };
subversion_1_9 = callPackageAlias "subversion" {
  channel = "1.9";
};
subversion_1_8 = callPackageAlias "subversion" {
  channel = "1.8";
};

sudo = callPackage ../all-pkgs/sudo { };

sushi = callPackage ../all-pkgs/sushi { };

swig_2 = callPackageAlias "swig" {
  channel = "2";
};

swig_3 = callPackageAlias "swig" {
  channel = "3";
};

swig = callPackage ../all-pkgs/swig { };

sydent = pkgs.python2Packages.sydent;

synapse = pkgs.python2Packages.synapse;

syncthing = pkgs.goPackages.syncthing.bin // { outputs = [ "bin" ]; };

syslinux = callPackage ../all-pkgs/syslinux { };

sysstat = callPackage ../all-pkgs/sysstat { };

# TODO: Rename back to systemd once depedencies are sorted
systemd_full = callPackage ../all-pkgs/systemd { };

systemd_lib = callPackageAlias "systemd_full" {
  type = "lib";
};

talloc = callPackage ../all-pkgs/talloc { };

tcl_8-5 = callPackage ../all-pkgs/tcl {
  channel = "8.5";
};
tcl_8-6 = callPackage ../all-pkgs/tcl {
  channel = "8.6";
};
tcl = callPackageAlias "tcl_8-6" { };

tcp-wrappers = callPackage ../all-pkgs/tcp-wrappers { };

tdb = callPackage ../all-pkgs/tdb { };

#teamspeak_client = callPackage ../all-pkgs/teamspeak/client.nix { };
#teamspeak_server = callPackage ../all-pkgs/teamspeak/server.nix { };

tesseract = callPackage ../all-pkgs/tesseract { };

tevent = callPackage ../all-pkgs/tevent { };

texinfo = callPackage ../all-pkgs/texinfo { };

thin-provisioning-tools = callPackage ../all-pkgs/thin-provisioning-tools { };

tinc_1_0 = callPackage ../all-pkgs/tinc { channel = "1.0"; };
tinc_1_1 = callPackage ../all-pkgs/tinc { channel = "1.1"; };

tk_8-5 = callPackage ../all-pkgs/tk {
  channel = "8.5";
};
tk_8-6 = callPackage ../all-pkgs/tk {
  channel = "8.6";
};
tk = callPackageAlias "tk_8-6" { };

tmux = callPackage ../all-pkgs/tmux { };

totem-pl-parser = callPackage ../all-pkgs/totem-pl-parser { };

tracker = callPackage ../all-pkgs/tracker { };

tslib = callPackage ../all-pkgs/tslib { };

tzdata = callPackage ../all-pkgs/tzdata { };

udisks = callPackage ../all-pkgs/udisks { };

uefi-shell = callPackage ../all-pkgs/uefi-shell { };

ufraw = callPackage ../all-pkgs/ufraw { };

uhub = callPackage ../all-pkgs/uhub { };

uid_wrapper = callPackage ../all-pkgs/uid_wrapper { };

unbound = callPackage ../all-pkgs/unbound { };

unrar = callPackage ../all-pkgs/unrar { };

upower = callPackage ../all-pkgs/upower { };

usbmuxd = callPackage ../all-pkgs/usbmuxd { };

util-linux_full = callPackage ../all-pkgs/util-linux { };

util-linux_lib = callPackageAlias "util-linux_full" {
  type = "lib";
};

vaapi-intel = callPackage ../all-pkgs/vaapi-intel { };

vala = callPackage ../all-pkgs/vala { };

vault = pkgs.goPackages.vault.bin // { outputs = [ "bin" ]; };

v4l-utils = callPackage ../all-pkgs/v4l-utils {
  channel = "utils";
};
v4l_lib = callPackageAlias "v4l-utils" {
  channel = "lib";
};

vim = callPackage ../all-pkgs/vim { };

vino = callPackage ../all-pkgs/vino { };

vlc = callPackage ../all-pkgs/vlc { };

vorbis-tools = callPackage ../all-pkgs/vorbis-tools { };

vte = callPackage ../all-pkgs/vte { };

w3m = callPackage ../all-pkgs/w3m { };

waf = callPackage ../all-pkgs/waf { };

wavpack = callPackage ../all-pkgs/wavpack { };

wayland = callPackage ../all-pkgs/wayland { };

wayland-protocols = callPackage ../all-pkgs/wayland-protocols { };

webkitgtk_2_4_gtk3 = callPackage ../all-pkgs/webkitgtk/2.4.x.nix {
  gtkVer = "3";
};
webkitgtk_2_4_gtk2 = callPackageAlias "webkitgtk_2_4_gtk3" {
  gtkVer = "2";
};
webkitgtk_2_4 = callPackageAlias "webkitgtk_2_4_gtk3" { };
webkitgtk = callPackage ../all-pkgs/webkitgtk { };

wget = callPackage ../all-pkgs/wget { };

which = callPackage ../all-pkgs/which { };

wiredtiger = callPackage ../all-pkgs/wiredtiger { };

wireguard = callPackage ../all-pkgs/wireguard {
  kernel = null;
};

wxGTK = callPackage ../all-pkgs/wxGTK { };

x264 = callPackage ../all-pkgs/x264 { };

x265 = callPackage ../all-pkgs/x265 { };

xdg-utils = callPackage ../all-pkgs/xdg-utils { };

xf86-input-mtrack = callPackage ../all-pkgs/xf86-input-mtrack { };

xf86-input-wacom = callPackage ../all-pkgs/xf86-input-wacom { };

xfe = callPackage ../all-pkgs/xfe { };

xfsprogs = callPackage ../all-pkgs/xfsprogs { };
xfsprogs_lib = pkgs.xfsprogs.lib;

xine-lib = callPackage ../all-pkgs/xine-lib { };

xine-ui = callPackage ../all-pkgs/xine-ui { };

xmlto = callPackage ../all-pkgs/xmlto { };

xmltoman = callPackage ../all-pkgs/xmltoman { };

xorg = recurseIntoAttrs (
  lib.callPackagesWith pkgs ../all-pkgs/xorg/default.nix {
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

xz = callPackage ../all-pkgs/xz { };

yaml-cpp = callPackage ../all-pkgs/yaml-cpp { };

yasm = callPackage ../all-pkgs/yasm { };

yelp-tools = callPackage ../all-pkgs/yelp-tools { };

yelp-xsl = callPackage ../all-pkgs/yelp-xsl { };

zeitgeist = callPackage ../all-pkgs/zeitgeist { };

zenity = callPackage ../all-pkgs/zenity {
  webkitgtk = null;
};

zeromq = callPackage ../all-pkgs/zeromq { };

zip = callPackage ../all-pkgs/zip { };

zita-convolver = callPackage ../all-pkgs/zita-convolver { };

zita-resampler = callPackage ../all-pkgs/zita-resampler { };

zlib = callPackage ../all-pkgs/zlib { };

zsh = callPackage ../all-pkgs/zsh { };

zstd = callPackage ../all-pkgs/zstd { };

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
  gtest = callPackage ../development/libraries/gtest {};
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
  rpm = callPackage ../tools/package-management/rpm { };
#
  sg3_utils = callPackage ../tools/system/sg3_utils { };
#
  strongswan = callPackage ../tools/networking/strongswan { };
#
  tcpdump = callPackage ../tools/networking/tcpdump { };
#
  trousers = callPackage ../tools/security/trousers { };
#
  vobsub2srt = callPackage ../tools/cd-dvd/vobsub2srt { };
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
  gom = callPackage ../all-pkgs/gom { };
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
  libkate = callPackage ../development/libraries/libkate { };
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

  speexdsp = callPackage ../development/libraries/speexdsp { };
#
  sqlite-interactive = pkgs.sqlite;
#
  t1lib = callPackage ../development/libraries/t1lib { };

  taglib = callPackage ../development/libraries/taglib { };
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
  apache-httpd = callPackage ../all-pkgs/apache-httpd  { };

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

  linux_4_6 = callPackage ../os-specific/linux/kernel {
    channel = "4.6";
    kernelPatches = [ pkgs.kernelPatches.bridge_stp_helper ];
  };

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

      nvidia-drivers_legacy304 = kCallPackage ../all-pkgs/nvidia-drivers {
        channel = "legacy304";
      };
      nvidia-drivers_legacy340 = kCallPackage ../all-pkgs/nvidia-drivers {
        channel = "legacy340";
      };
      nvidia-drivers_tesla = kCallPackage ../all-pkgs/nvidia-drivers {
        channel = "tesla";
      };
      nvidia-drivers_long-lived = kCallPackage ../all-pkgs/nvidia-drivers {
        channel = "long-lived";
      };
      nvidia-drivers_short-lived = kCallPackage ../all-pkgs/nvidia-drivers {
        channel = "short-lived";
      };
      nvidia-drivers_beta = kCallPackage ../all-pkgs/nvidia-drivers {
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

      wireguard = kCallPackage ../all-pkgs/wireguard {
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
  linuxPackages = pkgs.linuxPackages_4_6;
  linux = pkgs.linuxPackages.kernel;
#
#  # Update this when adding the newest kernel major version!
  linuxPackages_latest = pkgs.linuxPackages_4_7;
  linux_latest = pkgs.linuxPackages_latest.kernel;
#
#  # Build the kernel modules for the some of the kernels.
  linuxPackages_4_6 = recurseIntoAttrs (pkgs.linuxPackagesFor {
    kernel = pkgs.linux_4_6;
  });
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
    callPackage ../all-pkgs/kmod/aggregator.nix {
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
  cantarell_fonts = callPackage ../data/fonts/cantarell-fonts { };
#
  dejavu_fonts = callPackage ../data/fonts/dejavu-fonts { };
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
  liberation_ttf_from_source = callPackage ../data/fonts/redhat-liberation-fonts { };
  liberation_ttf_binary = callPackage ../data/fonts/redhat-liberation-fonts/binary.nix { };
  liberation_ttf = pkgs.liberation_ttf_binary;
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
  #mediainfo = callPackage ../applications/misc/mediainfo { };
#
  mp3val = callPackage ../applications/audio/mp3val { };
#
  mpg123 = callPackage ../applications/audio/mpg123 { };
#
  mujs = callPackage ../all-pkgs/mujs { };

  mupdf = callPackage ../all-pkgs/mupdf {
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
  xdg-user-dirs = callPackage ../tools/X11/xdg-user-dirs { };
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
