{ stdenv
, deterministic-zip
, curl
, git
, openssl
, textencode
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
, multihash ? ""
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

assert sha256 != "";
assert deepClone -> leaveDotGit;

let
  mirrors = import ../fetchurl/mirrors.nix;
in
stdenv.mkDerivation {
  innerName = name;
  name = "${name}.tar.br";
  builder = ./builder.sh;
  fetcher = ./nix-prefetch-git;
  nativeBuildInputs = [
    (deterministic-zip.override { inherit version; })
    curl
    git
    openssl
    textencode
  ];

  outputHashAlgo = "sha256";
  outputHashMode = "flat";
  outputHash = sha256;

  inherit
    url
    rev
    multihash
    leaveDotGit
    fetchSubmodules
    deepClone
    branchName;

  impureEnvVars = [
    # We borrow these environment variables from the caller to allow
    # easy proxy configuration.  This is impure, but a fixed-output
    # derivation like fetchurl is allowed to do so since its result is
    # by definition pure.
    "HTTP_PROXY"
    "HTTPS_PROXY"
    "FTP_PROXY"
    "ALL_PROXY"
    "NO_PROXY"

    # Git specific variables
    "GIT_PROXY_COMMAND"
    "SOCKS_SERVER"

    # This variable allows the user to pass additional options to curl
    "NIX_CURL_FLAGS"

    # This allows the end user to specify the local ipfs host:port which hosts
    # the content
    "IPFS_API"
  ];

  # Write the list of mirrors to a file that we can reuse between
  # fetchurl instantiations, instead of passing the mirrors to
  # fetchurl instantiations via environment variables.  This makes the
  # resulting store derivations (.drv files) much smaller, which in
  # turn makes nix-env/nix-instantiate faster.
  mirrorsFile = stdenv.mkDerivation {
    name = "mirrors-list";
    buildCommand = stdenv.lib.concatStrings (
      stdenv.lib.flip stdenv.lib.mapAttrsToList mirrors (mirror: urls: ''
        echo '${mirror} ${stdenv.lib.concatStringsSep " " urls}' >> "$out"
      '')
    );
    preferLocalBuild = true;
  };

  preferLocalBuild = true;
}
