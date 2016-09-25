{stdenv
, git
, gnutar_1-29
, brotli_0-4-0
, brotli_0-5-2
}: let
  urlToName = url: rev: let
    base = baseNameOf (stdenv.lib.removeSuffix "/" url);

    matched = builtins.match "([^.]*)(.git)?" base;

    short = builtins.substring 0 7 rev;

    appendShort = if (builtins.match "[a-f0-9]*" rev) != null
      then "-${short}"
      else "";
  in "${if matched == null then base else builtins.head matched}${appendShort}";
in
{ url
, rev ? "HEAD"
, md5 ? ""
, sha256 ? ""
, leaveDotGit ? deepClone
, fetchSubmodules ? true
, deepClone ? false
, branchName ? null
, name ? urlToName url rev
, version ? null
}:

/* NOTE:
   fetchgit has one problem: git fetch only works for refs.
   This is because fetching arbitrary (maybe dangling) commits may be a security risk
   and checking whether a commit belongs to a ref is expensive. This may
   change in the future when some caching is added to git (?)
   Usually refs are either tags (refs/tags/*) or branches (refs/heads/*)
   Cloning branches will make the hash check fail when there is an update.
   But not all patches we want can be accessed by tags.

   The workaround is getting the last n commits so that it's likly that they
   still contain the hash we want.

   for now : increase depth iteratively (TODO)

   real fix: ask git folks to add a
   git fetch $HASH contained in $BRANCH
   facility because checking that $HASH is contained in $BRANCH is less
   expensive than fetching --depth $N.
   Even if git folks implemented this feature soon it may take years until
   server admins start using the new version?
*/

assert md5 != "" || sha256 != "";
assert deepClone -> leaveDotGit;
assert version != null || throw "Missing fetchzip version. The latest version is 2.";

let
  versions = {
    "1" = {
      brotli = brotli_0-4-0;
      tar = gnutar_1-29;
    };
    "2" = {
      brotli = brotli_0-5-2;
      tar = gnutar_1-29;
    };
  };

  inherit (versions."${toString version}")
    brotli
    tar;
in
stdenv.mkDerivation {
  innerName = name;
  name = "${name}.tar.br";
  builder = ./builder.sh;
  fetcher = stdenv.mkDerivation {
    name = "fetchgit-fetcher-hook";
    buildCommand = ''
      sed -e 's,@brotli@,${brotli},g' \
        -e 's,@tar@,${tar},g' ${./nix-prefetch-git} > $out
    '';
    preferLocalBuild = true;
  };
  buildInputs = [git];

  outputHashAlgo = if sha256 == "" then "md5" else "sha256";
  outputHashMode = "flat";
  outputHash = if sha256 == "" then md5 else sha256;

  inherit url rev leaveDotGit fetchSubmodules deepClone branchName;

  impureEnvVars = [
    # We borrow these environment variables from the caller to allow
    # easy proxy configuration.  This is impure, but a fixed-output
    # derivation like fetchurl is allowed to do so since its result is
    # by definition pure.
    "http_proxy" "https_proxy" "ftp_proxy" "all_proxy" "no_proxy" "GIT_PROXY_COMMAND" "SOCKS_SERVER"
    ];

  preferLocalBuild = true;
}
