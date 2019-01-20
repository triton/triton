#! @shell@ -e
path_backup="$PATH"
if [ -n "@coreutils@" ]; then
  PATH="@coreutils@/bin"
fi

if [ -n "$NIX_LD_WRAPPER_START_HOOK" ]; then
    source "$NIX_LD_WRAPPER_START_HOOK"
fi

if [ -z "$NIX_CC_WRAPPER_FLAGS_SET" ]; then
    source @out@/nix-support/add-flags.sh
fi

source @out@/nix-support/utils.sh

params=()

if [ "${dtRpath-$extraCCFlags}" = "1" ]; then
  params+=("--enable-new-dtags")
fi

if [ "${noexecstack-$extraCCFlags}" = "1" ]; then
  params+=("-z" "noexecstack")
fi

if [ "${relro-$extraCCFlags}" = "1" ]; then
  params+=("-z" "relro")
fi

if [ "${bindnow-$extraCCFlags}" = "1" ]; then
  params+=("-z" "now")
fi

params+=("$@")

# Optionally filter out paths not refering to the store.
if [ "$NIX_ENFORCE_PURITY" = 1 -a -n "$NIX_STORE" \
        -a \( -z "$NIX_IGNORE_LD_THROUGH_GCC" -o -z "$NIX_LDFLAGS_SET" \) ]; then
    rest=()
    n=0
    while [ $n -lt ${#params[*]} ]; do
        p=${params[n]}
        p2=${params[$((n+1))]}
        if [ "${p:0:3}" = -L/ ] && badPath "${p:2}"; then
            skip $p
        elif [ "$p" = -L ] && badPath "$p2"; then
            n=$((n + 1)); skip $p2
        elif [ "$p" = -rpath ] && badPath "$p2"; then
            n=$((n + 1)); skip $p2
        elif [ "$p" = -dynamic-linker ] && badPath "$p2"; then
            n=$((n + 1)); skip $p2
        elif [ "${p:0:1}" = / ] && badPath "$p"; then
            # We cannot skip this; barf.
            echo "impure path \`$p' used in link" >&2
            exit 1
        elif [ "${p:0:9}" = --sysroot ]; then
            # Our ld is not built with sysroot support (Can we fix that?)
            :
        else
            rest=("${rest[@]}" "$p")
        fi
        n=$((n + 1))
    done
    params=("${rest[@]}")
fi


extra=()
extraBefore=()

if [ -z "$NIX_LDFLAGS_SET" ]; then
    extra+=($NIX_LDFLAGS)
    extraBefore+=($NIX_LDFLAGS_BEFORE)
fi

extra+=($NIX_LDFLAGS_AFTER)


# Determine if we are dynamically linking
dynamicLibc=0
skipStatic=0
for param in "${params[@]}"; do
  if [ "$param" = -static ]; then
    skipStatic=1
  elif [ "$param" = -Bdynamic ]; then
    skipStatic=0
  elif [ "$param" = -Bstatic ]; then
    skipStatic=1
  elif [ "$skipStatic" -eq "0" ] && [ "$param" = "-lc" ]; then
    dynamicLibc=1
  fi
done
if [ "$dynamicLibc" -eq "1" ]; then
  extra+=($NIX_LDFLAGS_LIBC_DYNAMIC)
fi

# Add all used dynamic libraries to the rpath.
if [ "$NIX_DONT_SET_RPATH" != 1 ]; then

    libPath=""
    addToLibPath() {
        local path="$1"
        if [ "${path:0:1}" != / ]; then return 0; fi
        case "$path" in
            *..*|*./*|*/.*|*//*)
                local path2
                if path2=$(readlink -f "$path"); then
                    path="$path2"
                fi
                ;;
        esac
        case $libPath in
            *\ $path\ *) return 0 ;;
        esac
        libPath="$libPath $path "
    }

    addToRPath() {
        # If the path is not in the store, don't add it to the rpath.
        # This typically happens for libraries in /tmp that are later
        # copied to $out/lib.  If not, we're screwed.
        if [ "${1:0:${#NIX_STORE}}" != "$NIX_STORE" ]; then return 0; fi
        case $rpath in
            *\ $1\ *) return 0 ;;
        esac
        rpath="$rpath $1 "
    }

    libs=""
    addToLibs() {
        libs="$libs $1"
    }

    rpath=""

    # First, find all -L... switches.
    allParams=("${params[@]}" ${extra[@]})
    n=0
    skipStatic=0
    while [ $n -lt ${#allParams[*]} ]; do
        p=${allParams[n]}
        p2=${allParams[$((n+1))]}
        if [ "${p:0:3}" = -L/ ]; then
            addToLibPath ${p:2}
        elif [ "$p" = -L ]; then
            addToLibPath ${p2}
            n=$((n + 1))
        elif [ "$p" = -Bdynamic ]; then
            skipStatic=0
        elif [ "$p" = -Bstatic ]; then
            skipStatic=1
        elif [ "$p" = -l ]; then
            if [ "$skipStatic" -ne "1" ]; then
              addToLibs ${p2}
            fi
            n=$((n + 1))
        elif [ "${p:0:2}" = -l ]; then
            if [ "$skipStatic" -ne "1" ]; then
              addToLibs ${p:2}
            fi
        elif [ "$p" = -dynamic-linker ]; then
            # Ignore the dynamic linker argument, or it
            # will get into the next 'elif'. We don't want
            # the dynamic linker path rpath to go always first.
            n=$((n + 1))
        elif [ "$p" = -plugin ]; then
            # Ignore the plugin argument, or it
            # will get into the next 'elif'. We don't want
            # the linker plugins added to the rpath since they are only used
            # by the linker itself
            n=$((n + 1))
        elif [[ "$p" =~ ^[^-].*\.so($|\.) ]]; then
            # This is a direct reference to a shared library, so add
            # its directory to the rpath.
            path="$(dirname "$p")";
            addToRPath "${path}"
        fi
        n=$((n + 1))
    done

    # Second, for each directory in the library search path (-L...),
    # see if it contains a dynamic library used by a -l... flag.  If
    # so, add the directory to the rpath.
    # It's important to add the rpath in the order of -L..., so
    # the link time chosen objects will be those of runtime linking.

    for i in $libPath; do
        for j in $libs; do
            if [ -f "$i/lib$j.so" ]; then
                addToRPath $i
                break
            fi
        done
    done


    # Finally, add `-rpath' switches.
    for i in $rpath; do
        extra=(${extra[@]} -rpath $i)
    done
fi


# Optionally print debug info.
if [ -n "$NIX_DEBUG" ]; then
  echo "original flags to @prog@:" >&2
  for i in "${params[@]}"; do
      echo "  $i" >&2
  done
  echo "extra flags to @prog@:" >&2
  for i in ${extra[@]}; do
      echo "  $i" >&2
  done
fi

if [ -n "$NIX_LD_WRAPPER_EXEC_HOOK" ]; then
    source "$NIX_LD_WRAPPER_EXEC_HOOK"
fi

PATH="$path_backup"
exec @prog@ ${extraBefore[@]} "${params[@]}" ${extra[@]}
