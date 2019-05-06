rustcEnv() {
  export RUSTFLAGS_HOST="$RUSTFLAGS_HOST -L@std@/lib"
}

if [ -z "$rustcHookAdded" ]; then
  preConfigureHooks+=(rustcEnv)
  rustcHookAdded=1
fi
