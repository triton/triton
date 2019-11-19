set -e
set -o pipefail
set -u

source "$NIX_BUILD_TOP"/.attrs.sh

trap "exitHandler" EXIT

################################ Hook handling #################################

# Run all hooks with the specified name in the order in which they
# were added, stopping if any fails (returns a non-zero exit
# code). The hooks for <hookName> are the shell function or variable
# <hookName>, and the values of the shell array ‘<hookName>Hooks’.
runHook() {
  local hookName="$1"; shift

  if [[ "$hookName" = *Hook ]]; then
    local -n var="${hookName}s"
  else
    local -n var="${hookName}Hooks"
  fi

  for hook in "_callImplicitHook 0 $hookName" "${var[@]}"; do
    _eval "$hook" "$@"
  done

  return 0
}

# Run all hooks with the specified name, until one succeeds (returns a
# zero exit code). If none succeed, return a non-zero exit code.
runOneHook() {
  local hookName="$1"; shift

  if [[ "$hookName" = *Hook ]]; then
    local -n var="${hookName}s"
  else
    local -n var="${hookName}Hooks"
  fi

  for hook in "_callImplicitHook 1 $hookName" "${var[@]}"; do
    if _eval "$hook" "$@"; then
      return 0
    fi
  done

  return 1
}

# Run the named hook, either by calling the function with that name or
# by evaluating the variable with that name. This allows convenient
# setting of hooks both from Nix expressions (as attributes /
# environment variables) and from shell scripts (as functions). If you
# want to allow multiple hooks, use runHook instead.
_callImplicitHook() {
  local def="$1"
  local hookName="$2"

  case "$(type -t $hookName)" in
    'function'|'alias'|'builtin') $hookName ;;
    'file') source "$hookName" ;;
    'keyword') : ;;
    *)
      if [ -z "${!hookName-}" ]; then
        return "$def"
      else
        eval "${!hookName-}"
      fi
      ;;
  esac
}

# A function wrapper around ‘eval’ that ensures that ‘return’ inside
# hooks exits the hook, not the caller.
_eval() {
  local code="$1"; shift

  if [ "$(type -t $code)" = function ]; then
    eval "$code \"\$@\""
  else
    eval "$code"
  fi
}

################################### Logging ####################################

header() {
  echo "$1" >&"$NIX_LOG_FD"
}

################################ Error handling ################################

exitHandler() {
  exitCode=$?
  set +e

  if [ $exitCode != 0 ]; then
    runHook 'failureHook'

    # If the builder had a non-zero exit code and
    # $succeedOnFailure is set, create the file
    # ‘$out/nix-support/failed’ to signal failure, and exit
    # normally.  Otherwise, return the original exit code.
    if [ -n "${succeedOnFailure-}" ]; then
      echo "build failed with exit code $exitCode (ignored)"
      mkdir -p "${outputs["$defaultOutput"]}/nix-support"
      printf "%s" "$exitCode" > "${outputs["$defaultOutput"]}/nix-support/failed"
      exit 0
    fi
  else
    runHook 'exitHook'
  fi

  exit "$exitCode"
}

############################### Helper functions ###############################

addToSearchPathWithCustomDelimiter() {
  local delimiter="$1"
  local -n var="$2"
  local dir="$3"

  if [ -d "$dir" ]; then
    var=${var-}${var:+$delimiter}${dir}
  fi
}

addToSearchPath() {
  addToSearchPathWithCustomDelimiter "${PATH_DELIMITER}" "$@"
}

# Recursively find all build inputs.
findInputs() {
  local pkg="$1"
  local var="$2"
  local -n inputs="$2"
  local propagatedBuildInputsFile="$3"

  # Allow for null inputs
  if [ -z "$pkg" ]; then
    return 0
  fi

  local input
  for input in "${inputs[@]}"; do
    if [ "$pkg" = "$input" ]; then
      return 0
    fi
  done

  if [ ! -e "$pkg" ]; then
    echo "build input $pkg does not exist" >&2
    exit 1
  fi

  inputs+=("$pkg")

  if [ -f "$pkg" ]; then
    source "$pkg"
  fi

  if [ -d "$pkg"/bin ]; then
    addToSearchPath _PATH "$pkg"/bin
  fi

  if [ -f "$pkg/nix-support/setup-hook" ]; then
    source "$pkg/nix-support/setup-hook"
  fi

  if [ -f "$pkg/nix-support/$propagatedBuildInputsFile" ]; then
    for i in $(cat "$pkg/nix-support/$propagatedBuildInputsFile"); do
      findInputs "$i" "$var" "$propagatedBuildInputsFile"
    done
  fi
}

# Set the relevant environment variables to point to the build inputs
# found above.
_addToNativeEnv() {
  local pkg="$1"

  addToSearchPath '_PATH' "$1/bin"

  # Run the package-specific hooks set by the setup-hook scripts.
  runHook 'envHook' "$pkg"
}

_addToCrossEnv() {
  local pkg="$1"

  # Some programs put important build scripts (freetype-config and similar)
  # into their crossDrv bin path. Intentionally these should go after
  # the nativePkgs in PATH.
  addToSearchPath '_PATH' "$1/bin"

  # Run the package-specific hooks set by the setup-hook scripts.
  runHook 'crossEnvHook' "$pkg"
}

############################### Generic builder ################################

# This function is useful for debugging broken Nix builds.  It dumps
# all environment variables to a file `env-vars' in the build
# directory.  If the build fails and the `-K' option is used, you can
# then go to the build directory and source in `env-vars' to reproduce
# the environment used for building.
dumpVars() {
  if [ -n "${dumpEnvVars-true}" ]; then
    export > "$NIX_BUILD_TOP/env-vars" || true
  fi
}

# Utility function: return the base name of the given path, with the
# prefix `HASH-' removed, if present.
stripHash() {
  strippedName="$(basename "$1")";
  if echo "$strippedName" | grep -q '^[a-z0-9]\{32\}-'; then
    strippedName=$(echo "$strippedName" | cut -c34-)
  fi
}

_defaultUnpack() {
  local fn="$1"
  local ret="1"

  if [ -d "$fn" ]; then
    stripHash "$fn"

    # We can't preserve hardlinks because they may have been
    # introduced by store optimization, which might break things
    # in the build.
    cp -pr --reflink=auto "$fn" "$strippedName"
    ret=0
  else
    case "$fn" in
      *.tar.brotli | *.tar.bro | *.tar.br | *.tbr)
        brotli -d < "$fn" | tar x && ret=0 || ret="$?"
        ;;
      *.tar | *.tar.* | *.tgz | *.tbz2 | *.txz)
        # GNU tar can automatically select the decompression method
        # (info "(tar) gzip").
        tar xf "$fn" && ret=0 || ret="$?"
        ;;
    esac
  fi

  [ "$ret" -eq "0" ] || [ "$ret" -eq "141" ]
}

unpackFile() {
  curSrc="$1"
  header "unpacking source archive $curSrc" 3
  if ! runOneHook 'unpackCmd' "$curSrc"; then
    echo "do not know how to unpack source archive $curSrc"
    exit 1
  fi
}

unpackPhase() {
  runHook 'preUnpack'

  if [ -z "${srcs[*]-}" ]; then
    if [ -z "${src-}" ]; then
      echo 'variable $src or $srcs should point to the source'
      exit 1
    fi
    srcs=("$src")
  fi

  # To determine the source directory created by unpacking the
  # source archives, we record the contents of the current
  # directory, then look below which directory got added.  Yeah,
  # it's rather hacky.
  local dirsBefore=''
  for i in *; do
    if [ -d "$i" ]; then
      dirsBefore="$dirsBefore $i "
    fi
  done

  # Unpack all source archives.
  for i in "${srcs[@]}"; do
    unpackFile "$i"
  done

  # Find the source directory.
  if [ -n "${setSourceRoot-}" ]; then
    runOneHook 'setSourceRoot'
  elif [ -z "${srcRoot-}" ]; then
    srcRoot=
    for i in *; do
      if [ -d "$i" ]; then
        case $dirsBefore in
          *\ $i\ *)
            ;;
          *)
            if [ -n "$srcRoot" ]; then
              echo "unpacker produced multiple directories"
              exit 1
            fi
            srcRoot="$i"
            ;;
        esac
      fi
    done
  fi

  if [ -z "$srcRoot" ]; then
    echo "unpacker appears to have produced no directories"
    exit 1
  fi

  echo "source root is $srcRoot"

  # By default, add write permission to the sources.  This is often
  # necessary when sources have been copied from other store
  # locations.
  if [ -n "${makeSourcesWritable-true}" ]; then
    chmod -R u+w "$srcRoot"
  fi

  runHook 'postUnpack'
}

patchPhase() {
  runHook 'prePatch'

  for i in "${patches[@]}"; do
    header "applying patch $i" '3'
    local uncompress='cat'
    case "$i" in
      *.gz) uncompress='gzip -d' ;;
      *.bz2) uncompress='bzip2 -d' ;;
      *.xz) uncompress='xz -d' ;;
      *.lzma) uncompress='lzma -d' ;;
    esac
    # "2>&1" is a hack to make patch fail if the decompressor fails (nonexistent patch, etc.)
    $uncompress < "$i" 2>&1 | patch "${patchFlags[@]:--p1}"
  done

  runHook 'postPatch'
}

libtoolFix() {
  sed -i -e 's^eval sys_lib_.*search_path=.*^^' "$1"
}

configureScripted() {
  if [ -z "${configureScript-}" -a -x ./configure ]; then
    configureScript=./configure
  fi

  if test -z "${configureScript-}"; then
    echo "no configure script, doing nothing"
    return 0
  fi

  declare -ga configureFlags

  : ${addSystem=1}
  if [ -n "${addBuild-$addSystem}" -a -n "${NIX_SYSTEM_BUILD-}" ]; then
    if grep -q '\--build' "$configureScript" 2>/dev/null; then
      configureFlags+=("--build=$NIX_SYSTEM_BUILD")
    fi
  fi

  if [ -n "${addHost-$addSystem}" -a -n "${NIX_SYSTEM_HOST-}" ]; then
    if grep -q '\--host' "$configureScript" 2>/dev/null; then
      configureFlags+=("--host=$NIX_SYSTEM_HOST")
    fi
  fi

  if [ -n "${addPrefix-1}" ]; then
    configureFlags+=("${prefixKey:---prefix=}$prefix")
  fi

  # Add --disable-dependency-tracking to speed up some builds.
  if [ -n "${addDisableDepTrack-1}" ]; then
    if grep -q dependency-tracking "$configureScript" 2>/dev/null; then
      configureFlags+=("--disable-dependency-tracking")
    fi
  fi

  # Add --disable-maintainer-mode to reduce unnecessary regeneration.
  if [ -n "${addDisableMaintainerMode-1}" ]; then
    if grep -q maintainer-mode "$configureScript" 2>/dev/null; then
      configureFlags+=("--disable-maintainer-mode")
    fi
  fi

  # Add --enable-shared by default since we always want shared libs
  if [ -n "${addShared-1}" ]; then
    local flag=enable
    if [ -n "${disableShared-}" ]; then
      flag=disable
    fi
    if grep -q '\(enable\|disable\)-shared' "$configureScript" 2>/dev/null; then
      configureFlags+=("--$flag-shared")
    fi
  fi

  # By default, disable static builds if we don't have multiple outputs
  # for storing the static libs
  local defaultDisableStatic=1
  if [ -n "${outputs[dev]-}" ]; then
    defaultDisableStatic=
  fi
  if [ -n "${addStatic-1}" ]; then
    local flag=disable
    if [ -z "${disableStatic-$defaultDisableStatic}" ]; then
      flag=enable
    fi
    if grep -q '\(enable\|disable\)-static' "$configureScript" 2>/dev/null; then
      configureFlags+=("--$flag-static")
    fi
  fi

  if [ -n "$configureScript" ]; then
    echo "configure flags: ${configureFlags[@]}"
    $configureScript "${configureFlags[@]}"
  fi

}

configurePhase() {
  runHook 'preConfigure'

  if [ -n "${fixLibtool-1}" ]; then
    find . -iname "ltmain.sh" | while read i; do
      echo "fixing libtool script $i"
      libtoolFix "$i"
    done
  fi

  configureScripted

  runHook 'postConfigure'
}

commonMakeFlags() {
  local phaseName="$1"

  local -n parallel="${phaseName}Parallel"
  local -n phaseFlags="${phaseName}Flags"

  actualMakeFlags=()
  if [ -n "${makefile-}" ]; then
    actualMakeFlags+=('-f' "$makefile")
  fi
  if [ -n "${parallel-1}" ]; then
    actualMakeFlags+=("-j${NIX_BUILD_CORES}" "-l${NIX_BUILD_CORES}" "-O")
  fi
  actualMakeFlags+=("SHELL=$SHELL") # Needed for https://github.com/NixOS/nixpkgs/pull/1354#issuecomment-31260409
  if [ -n "${makeFlags[*]-}" ]; then
    actualMakeFlags+=("${makeFlags[@]}")
  fi
  if [ -n "${phaseFlags[*]-}" ]; then
    actualMakeFlags+=("${phaseFlags[@]}")
  fi
}

printMakeFlags() {
  local phaseName
  phaseName="$1"

  echo "$phaseName flags:"

  local flag
  for flag in "${actualMakeFlags[@]}"; do
    echo "  $flag"
  done
}

buildPhase() {
  runHook 'preBuild'

  if [ -z "${makeFlags[*]-}" ] && ! [ -n "${makefile-}" -o -e "Makefile" -o -e "makefile" -o -e "GNUmakefile" ]; then
    echo "no Makefile, doing nothing"
  else
    local actualMakeFlags
    commonMakeFlags 'build'
    printMakeFlags 'build'
    make "${actualMakeFlags[@]}"
  fi

  runHook 'postBuild'
}

checkPhase() {
  runHook 'preCheck'

  local actualMakeFlags
  commonMakeFlags 'check'
  actualMakeFlags+=("${checkFlags[@]:-VERBOSE=y}")
  actualMakeFlags+=("${checkTarget[@]:-check}")
  printMakeFlags 'check'
  make "${actualMakeFlags[@]}"

  runHook 'postCheck'
}

installPhase() {
  runHook 'preInstall'

  mkdir -p "$prefix"

  local actualMakeFlags
  commonMakeFlags 'install'
  actualMakeFlags+=("${installTargets[@]:-install}")
  printMakeFlags 'install'
  make "${actualMakeFlags[@]}"

  runHook 'postInstall'
}

# The fixup phase performs generic, package-independent stuff, like
# stripping binaries, running patchelf and setting
# propagated-build-inputs.
fixupPhase() {
  # Make sure everything is writable so "strip" et al. work.
  local output
  for output in "${outputs[@]}"; do
    if [ -e "$output" ]; then
      chmod -R u+w "$output"
    fi
  done

  runHook 'preFixup'

  # Apply fixup to each output.
  local prefix
  for prefix in "${outputs[@]}"; do
    runHook 'fixupOutput'
  done

  local supportDir="${outputs["$defaultOutput"]}/nix-support"
  if [ -n "${propagatedBuildInputs[*]}" ]; then
    mkdir -p "$supportDir"
    echo "${propagatedBuildInputs[*]}" > "$supportDir/propagated-build-inputs"
  fi

  if [ -n "${propagatedNativeBuildInputs[*]}" ]; then
    mkdir -p "$supportDir"
    echo "${propagatedNativeBuildInputs[*]}" > "$supportDir/propagated-native-build-inputs"
  fi

  if [ -n "${propagatedUserEnvPkgs[*]}" ]; then
    mkdir -p "$supportDir"
    echo "${propagatedUserEnvPkgs[*]}" > "$supportDir/nix-support/propagated-user-env-packages"
  fi

  runHook 'postFixup'
}

# The fixup check phase performs generic, package-independent checks
# like making sure that we don't have any impure paths in the contents
# of the resulting files.
fixupCheckPhase() {
  runHook 'preFixupCheck'

  # Apply fixup checks to each output.
  local prefix
  for output in "${outputs[@]}"; do
    runHook 'fixupCheckOutput'
  done

  runHook 'postFixupCheck'
}

installCheckPhase() {
  runHook 'preInstallCheck'

  local actualMakeFlags
  commonMakeFlags 'installCheck'
  actualMakeFlags+=(${installCheckTargets:-installcheck})
  printMakeFlags 'installCheck'
  make "${actualMakeFlags[@]}"

  runHook 'postInstallCheck'
}

distPhase() {
  runHook 'preDist'

  local actualMakeFlags
  commonMakeFlags 'dist'
  actualMakeFlags+=(${distTargets:-dist})
  printMakeFlags 'dist'
  make "${actualMakeFlags[@]}"

  if [ "${copyDist-1}" != "1" ]; then
    local tarballs="${outputs["$defaultOutput"]}/tarballs"
    mkdir -p "$tarballs"

    # Note: don't quote $tarballs, since we explicitly permit
    # wildcards in there.
    cp -pvd ${tarballs:-*.tar.*} "$tarballs"
  fi

  runHook 'postDist'
}

showPhaseHeader() {
  local phase="$1"
  case "$phase" in
    'unpackPhase') header 'unpacking sources' ;;
    'patchPhase') header 'patching sources' ;;
    'configurePhase') header 'configuring' ;;
    'buildPhase') header 'building' ;;
    'checkPhase') header 'running tests' ;;
    'installPhase') header 'installing' ;;
    'fixupPhase') header 'post-installation fixup' ;;
    'fixupCheckPhase') header 'post-installation fixup checks' ;;
    'installCheckPhase') header 'running install tests' ;;
    *) header "$phase" ;;
  esac
}

genericBuild() {
  if [ -n "${buildCommand-}" ]; then
    eval "$buildCommand"
    return
  fi

  if [ -n "${phases[*]-}" ]; then
    phases=($phases)
  else
    phases=(
      "${prePhases[@]}"
      'unpackPhase'
      'patchPhase'
      "${preConfigurePhases[@]}"
      'configurePhase'
      "${preBuildPhases[@]}"
      'buildPhase'
      'checkPhase'
      "${preInstallPhases[@]}"
      'installPhase'
      "${preFixupPhases[@]}"
      'fixupPhase'
      'fixupCheckPhase'
      'installCheckPhase'
      "${preDistPhases[@]}"
      'distPhase'
      "${postPhases[@]}"
    )
  fi

  for curPhase in "${phases[@]}"; do
    if [ "$curPhase" = 'buildPhase' -a -z "${doBuild-1}" ]; then continue; fi
    if [ "$curPhase" = 'checkPhase' -a -z "${doCheck-}" ]; then continue; fi
    if [ "$curPhase" = 'installPhase' -a -z "${doInstall-1}" ]; then continue; fi
    if [ "$curPhase" = 'fixupPhase' -a -z "${doFixup-1}" ]; then continue; fi
    if [ "$curPhase" = 'fixupCheckPhase' -a -z "${doFixupCheck-1}" ]; then continue; fi
    if [ "$curPhase" = 'installCheckPhase' -a -z "${doInstallCheck-}" ]; then continue; fi
    if [ "$curPhase" = 'distPhase' -a -z "${doDist-}" ]; then continue; fi

    if [ -n "${tracePhases-}" ]; then
      echo
      echo "@ phase-started $name $curPhase"
    fi

    showPhaseHeader "$curPhase"
    dumpVars

    # Evaluate the variable named $curPhase if it exists, otherwise the
    # function named $curPhase.
    eval "${!curPhase:-$curPhase}"

    if [ "$curPhase" = 'unpackPhase' ]; then
      cd "${srcRoot:-.}"
    fi

    if [ -n "${tracePhases-}" ]; then
      echo
      echo "@ phase-succeeded $name $curPhase"
    fi
  done
}

################################ Initialisation ################################

PATH_DELIMITER=':'

# Set a temporary locale that should be used by everything
LOCALE_PREDEFINED=${LC_ALL:+1}
export LC_ALL
: ${LC_ALL:=C}

# Set a fallback default value for SOURCE_DATE_EPOCH, used by some
# build tools to provide a deterministic substitute for the "current"
# time. Note that 1 = 1970-01-01 00:00:01. We don't use 0 because it
# confuses some applications.
export SOURCE_DATE_EPOCH
: ${SOURCE_DATE_EPOCH:=1}

# Wildcard expansions that don't match should expand to an empty list.
# This ensures that, for instance, "for i in *; do ...; done" does the
# right thing.
shopt -s nullglob

# Set up the initial path.
PATH=
for i in "${initialPath[@]}"; do
  if [ "$i" = / ]; then
    i=
  fi
  addToSearchPath 'PATH' "$i/bin"
done

if [ -n "${NIX_DEBUG-}" ]; then
  echo "initial path: $PATH"
fi

# Check that the pre-hook initialised SHELL.
if [ -z "${SHELL-}" ]; then
  echo "SHELL not set"
  exit 1
fi
BASH="$SHELL"
export CONFIG_SHELL="$SHELL"

# Set the TZ (timezone) environment variable, otherwise commands like
# `date' will complain (e.g., `Tue Mar 9 10:01:47 Local time zone must
# be set--see zic manual page 2004').
export TZ='UTC'

# Before doing anything else, state the build time
NIX_BUILD_START="$(date '+%s')"

# Create legacy output variables
for output in "${!outputs[@]}"; do
  declare -g "$output=${outputs["$output"]}"
done

_PATH=""

runHook 'preHook'

# Allow the caller to augment buildInputs (it's not always possible to
# do this before the call to setup.sh, since the PATH is empty at that
# point; here we have a basic Unix environment).
runHook 'addInputsHook'

crossPkgs=()
for i in "${buildInputs[@]}" "${defaultBuildInputs[@]}" "${propagatedBuildInputs[@]}"; do
  findInputs "$i" 'crossPkgs' 'propagated-build-inputs'
done

nativePkgs=()
for i in "${nativeBuildInputs[@]}" "${defaultNativeBuildInputs[@]}" "${propagatedNativeBuildInputs[@]}"; do
  findInputs "$i" 'nativePkgs' 'propagated-native-build-inputs'
done

for i in "${nativePkgs[@]}"; do
  _addToNativeEnv "$i"
done

for i in "${crossPkgs[@]}"; do
  _addToCrossEnv "$i"
done

# Set the prefix.  This is generally $out, but it can be overriden,
# for instance if we just want to perform a test build/install to a
# temporary location and write a build report to $out.
if [ -z "${prefix-}" ]; then
  prefix="${outputs["$defaultOutput"]}"
fi

if [ -n "${useTempPrefix-}" ]; then
  prefix="$NIX_BUILD_TOP/tmp_prefix"
fi

PATH=$_PATH${_PATH:+:}$PATH
if [ -n "${NIX_DEBUG-}" ]; then
  echo "final path: $PATH"
fi

# Normalize the NIX_BUILD_CORES variable. The value might be 0, which
# means that we're supposed to try and auto-detect the number of
# available CPU cores at run-time.
if [ -z "${NIX_BUILD_CORES//[^0-9]/}" ]; then
  NIX_BUILD_CORES='1'
elif [ "$NIX_BUILD_CORES" -le 0 ]; then
  NIX_BUILD_CORES=$(nproc 2>/dev/null || true)
  if expr >/dev/null 2>&1 "$NIX_BUILD_CORES" : "^[0-9][0-9]*$"; then
    :
  else
    NIX_BUILD_CORES='1'
  fi
fi

unpackCmdHooks+=('_defaultUnpack')

# Execute the post-hooks.
runHook 'postHook'

# Execute the global user hook (defined through the Nixpkgs
# configuration option ‘stdenv.userHook’).  This can be used to set
# global compiler optimisation flags, for instance.
runHook 'userHook'

dumpVars
