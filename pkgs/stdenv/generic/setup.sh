################################ Hook handling #################################

# Run all hooks with the specified name in the order in which they
# were added, stopping if any fails (returns a non-zero exit
# code). The hooks for <hookName> are the shell function or variable
# <hookName>, and the values of the shell array ‘<hookName>Hooks’.
runHook() {
  local hookName="$1"; shift
  local var="$hookName"

  if [[ "$hookName" =~ Hook$ ]]; then
    var+='s'
  else
    var+='Hooks'
  fi

  eval "local -a dummy=(\"\${$var[@]}\")"

  for hook in "_callImplicitHook 0 $hookName" "${dummy[@]}"; do
    _eval "$hook" "$@"
  done

  return 0
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
      if [ -z "${!hookName}" ]; then
        return "$def"
      else
        eval "${!hookName}"
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

startNest() {
  nestingLevel=$(( $nestingLevel + 1 ))
  echo -en "\033[$1p"
}

stopNest() {
  nestingLevel=$(( $nestingLevel - 1 ))
  echo -en "\033[q"
}

header() {
  startNest "$2"
  echo "$1"
}

# Make sure that even when we exit abnormally, the original nesting
# level is properly restored.
closeNest() {
  while [ $nestingLevel -gt 0 ]; do
    stopNest
  done
}

################################ Error handling ################################

exitHandler() {
  local exitCode="$?"
  set +e

  closeNest

  if [ -n "$showBuildStats" ]; then
    times > "$NIX_BUILD_TOP/.times"
    local -a times=($(cat "$NIX_BUILD_TOP/.times"))
    # Print the following statistics:
    # - user time for the shell
    # - system time for the shell
    # - user time for all child processes
    # - system time for all child processes
    echo "build time elapsed: " ${times[*]}
  fi

  if [ $exitCode != 0 ]; then
    runHook 'failureHook'

    # If the builder had a non-zero exit code and
    # $succeedOnFailure is set, create the file
    # ‘$out/nix-support/failed’ to signal failure, and exit
    # normally.  Otherwise, return the original exit code.
    if [ -n "$succeedOnFailure" ]; then
      echo "build failed with exit code $exitCode (ignored)"
      mkdir -p "$out/nix-support"
      printf "%s" "$exitCode" > "$out/nix-support/failed"
      exit 0
    fi
  else
    runHook 'exitHook'
  fi

  exit "$exitCode"
}
trap "exitHandler" EXIT


############################### Helper functions ###############################

arrayToDict() {
  local tmp=(${!1})
  declare -gA "$1"
  eval "$1"='()'
  local i=1
  while [ "$i" -lt "${#tmp[@]}" ]; do
    eval "$1[\"${tmp[$(( $i - 1 ))]}\"]"='"${tmp[$i]}"'
    i=$(( $i + 2 ))
  done
}

# A generic mechanism for running chained hooks to take an input file and
# apply it over top of the environment.
# Hooks should manipulate the following local variables to affect execution:
#   - srcFile: The name of the file
#   - canApply: Whether or not to finish generating the application command
#   - cmd: The command which is run to apply to the file
# Hooks can be set by appending to the ${applyName}CmdGenerator array
# Examples where this is used can be found in the unpackPhase and patchPhase.
applyFile() {
  local applyName="$1"
  local srcFileOrig="$2"

  local -n generatorArr="${applyName}CmdGenerators"

  local srcFile="$srcFileOrig"
  local canApply=0
  local cmd=('cat' "$srcFile")
  local i=0
  while [ "$canApply" -ne '1' ] && [ "$i" -lt "${#generatorArr[@]}" ]; do
    if "${generatorArr[$i]}"; then
      i=0
    else
      i=$(( $i + 1 ))
    fi
  done

  if [ "$canApply" -ne '1' ]; then
    echo "Do not know how to $applyName $srcFile"
    exit 1
  fi

  header "${applyName}ing $srcFileOrig" 3
  eval "${cmd[@]}"
  stopNest
}

printFlags() {
  local phaseName="$1"
  local -n flagsRef="$2"

  echo "$phaseName flags:"

  local flag
  for flag in "${flagsRef[@]}"; do
    echo "  $flag"
  done
}

addToSearchPathWithCustomDelimiter() {
  local delimiter="$1"
  local varName="$2"
  local dir="$3"

  if [ -d "$dir" ]; then
    eval export ${varName}=${!varName}${!varName:+$delimiter}${dir}
  fi
}

addToSearchPath() {
  addToSearchPathWithCustomDelimiter "${PATH_DELIMITER}" "$@"
}

hasOutput() {
  local target="$1"

  [ "${outputsHash["$target"]}" = "1" ]
}

######################## Textual substitution functions ########################

substitute() {
  local input="$1"
  local output="$2"

  local -a params=("$@")

  local n p pattern replacement varName content

  # a slightly hacky way to keep newline at the end
  content="$(cat "$input"; printf "%s" X)"
  content="${content%X}"

  for (( n = 2; n < ${#params[*]}; n += 1 )); do
    p=${params[$n]}

    if [ "$p" = '--replace' ]; then
      pattern="${params[$((n + 1))]}"
      replacement="${params[$((n + 2))]}"
      n=$((n + 2))
    fi

    if [ "$p" = '--subst-var' ]; then
      varName="${params[$((n + 1))]}"
      pattern="@$varName@"
      replacement="${!varName}"
      n=$((n + 1))
    fi

    if [ "$p" = '--subst-var-by' ]; then
      pattern="@${params[$((n + 1))]}@"
      replacement="${params[$((n + 2))]}"
      n=$((n + 2))
    fi

    content="${content//"$pattern"/$replacement}"
  done

  printf "%s" "$content" > "$output"
}

substituteInPlace() {
  local fileName="$1"; shift

  substitute "$fileName" "$fileName" "$@"
}

substituteAll() {
  local input="$1"
  local output="$2"

  # Select all environment variables
  for envVar in $(env -0 | sed -z -n 's,^\([^=]*\).*,\1,p' | tr '\0' '\n'); do
    if [ "$NIX_DEBUG" = "1" ]; then
      echo "$envVar -> ${!envVar}"
    fi
    args="$args --subst-var $envVar"
  done

  substitute "$input" "$output" $args
}

substituteAllInPlace() {
  local fileName="$1"; shift

  substituteAll "$fileName" "$fileName" "$@"
}

################################################################################

# Recursively find all build inputs.
findInputs() {
  local pkg="$1"
  local var="$2"
  local propagatedBuildInputsFile="$3"

  case ${!var} in
    *\ $pkg\ *)
      return 0
      ;;
  esac

  eval $var="'${!var} $pkg '"

  if ! [ -e "$pkg" ]; then
    echo "build input $pkg does not exist" >&2
    exit 1
  fi

  if [ -f "$pkg" ]; then
    source "$pkg"
  fi

  if [ -d $1/bin ]; then
    addToSearchPath _PATH $1/bin
  fi

  if [ -f "$pkg/nix-support/setup-hook" ]; then
    source "$pkg/nix-support/setup-hook"
  fi

  if [ -f "$pkg/nix-support/$propagatedBuildInputsFile" ]; then
    for i in $(cat "$pkg/nix-support/$propagatedBuildInputsFile"); do
      findInputs "$i" $var $propagatedBuildInputsFile
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

# The fixup phase performs generic, package-independent stuff, like
# stripping binaries, running patchelf and setting
# propagated-build-inputs.
fixupPhase() {
  runHook 'preFixup'

  # Apply fixup to each output.
  local output
  for output in $outputs; do
    prefix=${!output} runHook 'fixupOutput'
  done

  if [ -n "$propagatedBuildInputs" ]; then
    mkdir -p "$out/nix-support"
    echo "$propagatedBuildInputs" > "$out/nix-support/propagated-build-inputs"
  fi

  if [ -n "$propagatedNativeBuildInputs" ]; then
    mkdir -p "$out/nix-support"
    echo "$propagatedNativeBuildInputs" > "$out/nix-support/propagated-native-build-inputs"
  fi

  if [ -n "$propagatedUserEnvPkgs" ]; then
    mkdir -p "$out/nix-support"
    echo "$propagatedUserEnvPkgs" > "$out/nix-support/propagated-user-env-packages"
  fi

  if [ "${#setupHook[@]}" -gt '0' ]; then
    mkdir -p "$out"/nix-support
    if test -f "$out"/nix-support/setup-hook; then
      echo "We already have a setup-hook"
      exit 1
    fi
    local setupHook
    for setupHook in "${setupHooks[@]}"; do
      substituteAll "$setupHook" setup-hook-tmp
      cat setup-hook-tmp >> "$out"/nix-support/setup-hook
    done
  fi

  runHook 'postFixup'
}

# The fixup check phase performs generic, package-independent checks
# like making sure that we don't have any impure paths in the contents
# of the resulting files.
fixupCheckPhase() {
  runHook 'preFixupCheck'

  # Apply fixup checks to each output.
  local output
  for output in $outputs; do
    prefix=${!output} runHook 'fixupCheckOutput'
  done

  runHook 'postFixupCheck'
}

phaseHeader() {
  local phase="$1"

  if [[ "$phase" =~ Phase$ ]]; then
    phase="${phase:0:-5}"
  fi

  if [ "${#phase}" -gt '20' ]; then
    echo "Phase name too long: $phase"
    exit 1
  fi

  header "$(printf '########## %-20s %37s ##########\n' "${phase^}" "$name")"
}

genericBuild() {
  if [ -n "$buildCommand" ]; then
    eval "$buildCommand"
    return
  fi

  # Make our default directory empty and immutable so scripting has
  # to be more specific about how it operates
  mkdir -p "$TMPDIR"/empty
  chattr +i "$TMPDIR"/empty 2>/dev/null || echo "WARNING: Missing chattr"
  cd "$TMPDIR"/empty

  if [ -z "$buildType" ] || [ "$buildType" = "normal" ]; then
    phases=(
      "${prePhases[@]}"
      'unpackPhase'
      'patchPhase'
      'configurePhase'
      'buildPhase'
      ${doCheck:+checkPhase}
      'installPhase'
      ${doInstallCheck:+installCheckPhase}
      'fixupPhase'
      'fixupCheckPhase'
      "${postPhases[@]}"
    )
  elif [ "$buildType" = "dist" ]; then
    phases=(
      "${prePhases[@]}"
      'unpackPhase'
      'patchPhase'
      'configurePhase'
      'distPhase'
      'fixupPhase'
      'fixupCheckPhase'
      "${postPhases[@]}"
    )
  else
    echo "Unsupported build type"
    exit 1
  fi

  local phase
  for phase in "${phases[@]}"; do
    phaseHeader "$phase"

    # Evaluate the variable named $curPhase if it exists, otherwise the
    # function named $curPhase.
    eval "${!phase:-$phase}"

    stopNest
  done
}

################################ Initialisation ################################

: ${outputs:=out}
declare -A outputsHash
for output in $outputs; do
  outputsHash["$output"]=1
done

# Array handling, we need to turn some variables into arrays
prePhases=($prePhases)
postPhases=($postPhases)
srcs=($srcs $src)
setupHooks=($setupHooks $setupHook)
patches=($patches)

arrayToDict patchVars

PATH_DELIMITER=':'

nestingLevel=0

# Wildcard expansions that don't match should expand to an empty list.
# This ensures that, for instance, "for i in *; do ...; done" does the
# right thing.
shopt -s nullglob

# Set up the initial path.
PATH=""
for i in $initialPath; do
  addToSearchPath 'PATH' "$i/bin"
done

if [ "$NIX_DEBUG" = 1 ]; then
  echo "initial path: $PATH"
fi

# Set the TZ (timezone) environment variable, otherwise commands like
# `date' will complain (e.g., `Tue Mar 9 10:01:47 Local time zone must
# be set--see zic manual page 2004').
export TZ='UTC'

# Before doing anything else, state the build time
NIX_BUILD_START="$(date '+%s')"

runHook 'preHook'

# Allow the caller to augment buildInputs (it's not always possible to
# do this before the call to setup.sh, since the PATH is empty at that
# point; here we have a basic Unix environment).
runHook 'addInputsHook'

crossPkgs=''
for i in $buildInputs $defaultBuildInputs $propagatedBuildInputs; do
  findInputs "$i" 'crossPkgs' 'propagated-build-inputs'
done

nativePkgs=''
for i in $nativeBuildInputs $defaultNativeBuildInputs $propagatedNativeBuildInputs; do
  findInputs "$i" 'nativePkgs' 'propagated-native-build-inputs'
done

# We want to allow builders to apply setup-hooks to themselves
if [ "${selfApplySetupHook-0}" = "1" ]; then
  source "$setupHook"
fi

for i in $nativePkgs; do
  _addToNativeEnv "$i"
done

for i in $crossPkgs; do
  _addToCrossEnv "$i"
done

# Add the output as an rpath.
if [ "$NIX_NO_SELF_RPATH" != 1 ]; then
  export NIX_LDFLAGS="-rpath $out/lib $NIX_LDFLAGS"
  if [ -n "$NIX_LIB64_IN_SELF_RPATH" ]; then
    export NIX_LDFLAGS="-rpath $out/lib64 $NIX_LDFLAGS"
  fi
  if [ -n "$NIX_LIB32_IN_SELF_RPATH" ]; then
    export NIX_LDFLAGS="-rpath $out/lib32 $NIX_LDFLAGS"
  fi
fi

# Set the prefix.  This is generally $out, but it can be overriden,
# for instance if we just want to perform a test build/install to a
# temporary location and write a build report to $out.
if [ -z "$prefix" ]; then
  prefix="$out"
fi

if [ "$useTempPrefix" = 1 ]; then
  prefix="$NIX_BUILD_TOP/tmp_prefix"
fi

PATH=$_PATH${_PATH:+:}$PATH
if [ "$NIX_DEBUG" = 1 ]; then
  echo "final path: $PATH"
fi

# Make GNU Make produce nested output.
export NIX_INDENT_MAKE=1

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
export NIX_BUILD_CORES

# Execute the post-hooks.
runHook 'postHook'

# Execute the global user hook (defined through the Nixpkgs
# configuration option ‘stdenv.userHook’).  This can be used to set
# global compiler optimisation flags, for instance.
runHook 'userHook'
