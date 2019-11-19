# The Nixpkgs CC is not directly usable, since it doesn't know where
# the C library and standard header files are. Therefore the compiler
# produced by that package cannot be installed directly in a user
# environment and used from the command line. So we use a wrapper
# script that sets up the right environment variables so that the
# compiler and the linker just "work".

{ stdenv
, cc
, lib
, fetchurl
}:

lib.makeOverridable
({ compiler
, tools ? [ ]
, inputs ? [ ]
, type ? "host"
}:

let
  inherit (lib)
    concatStringsSep
    hasPrefix
    optionalString;

  inherit (compiler)
    impl
    target
    prefixMapFlag;

  typefx = {
    "build" = "_FOR_BUILD";
    "host" = "";
  }."${type}";

  targetfx = if target == null then "" else "${target}-";

  tooldirs = map (n: "${n}/bin") (tools ++ [ compiler ]);

  target' = if target != null then target else stdenv.targetSystem;

  external = compiler.external;

  version = "0.1.6";
in
assert target != "";
stdenv.mkDerivation rec {
  name = "cc-wrapper-${version}";

  src = fetchurl {
    url = "https://github.com/triton/cc-wrapper/releases/download/v${version}/${name}.tar.xz";
    sha256 = "da9305c99a205791ec9028efae12e8cd5923cb5fe392adcd18000b5728d32e73";
  };

  nativeBuildInputs = [
    cc
  ];

  preConfigure = ''
    configureFlags+=("--with-pure-prefixes=$NIX_STORE")

    exists() {
      [ -h "$1" -o -e "$1" ]
    }

    declare -gA vars=()
    maybeAppend() {
      local file="$1"
      local input="$2"

      exists "$input"/nix-support/"$file" || return 0
      vars["$file"]+="''${vars["$file"]+ }$(tr '\n' ' ' <"$input"/nix-support/"$file")"
    }

  '' + optionalString (!external && hasPrefix "i686" target') ''
    vars['cflags-before']+=" -march=prescott"
    vars['cflags-before']+=" -msse2"
    vars['cflags-before']+=" -mfpmath=sse"
  '' + optionalString (!external && hasPrefix "x86_64" target') ''
    vars['cflags-before']+=" -march=sandybridge"
    vars['cflags-before']+=" -mavx"
  '' + optionalString (!external && hasPrefix "powerpc64le" target') ''
    vars['cflags-before']+=" -mcpu=power9"
    vars['cflags-before']+=" -msecure-plt"
  '' + ''
    for inc in "$compiler" "''${tools[@]}" "''${inputs[@]}"; do
      maybeAppend stdinc "$inc"
      maybeAppend stdincxx "$inc"
      maybeAppend cflags "$inc"
      maybeAppend cflags-before "$inc"
      maybeAppend cflags-link "$inc"
      maybeAppend cxxflags "$inc"
      maybeAppend cxxflags-before "$inc"
      maybeAppend cxxflags-link "$inc"
      maybeAppend dynamic-linker "$inc"
      maybeAppend ldflags "$inc"
      maybeAppend ldflags-before "$inc"
      maybeAppend ldflags-dynamic "$inc"
    done

    if [ -n "''${vars['dynamic-linker']-}" -a ! -e "''${vars['dynamic-linker']-}" ]; then
      echo "Invalid dynamic-linker \"''${vars['dynamic-linker']}\""
      exit 1
    fi

    for var in "''${!vars[@]}"; do
      configureFlags+=("--with-$var=''${vars["$var"]}")
    done

    echo 'int main() { return 0; }' >main.c
    if $CC -o main main.c -flto 2>/dev/null; then
      echo 'Using LTO' >&2
      configureFlags+=(
        'CFLAGS=-O2 -flto'
        'CXXFLAGS=-O2 -flto'
      )
    fi
  '';

  configureFlags = [
    (optionalString (target != null) "--target=${target}")
    "--disable-tests"
    "--with-tooldirs=${concatStringsSep ":" tooldirs}"
    "--with-preferred-compiler=${impl}"
    "--with-prefix-map-flag-${impl}=${prefixMapFlag}"
    "--with-var-prefix=CC_WRAPPER${typefx}"
    "--with-build-dir-env-var=NIX_BUILD_TOP"
  ];

  postInstall = ''
    mkdir -p "''${outputs[out]}"/nix-support
    for var in "''${!vars[@]}"; do
      echo "''${vars["$var"]}" >"''${outputs[out]}"/nix-support/"$var"
    done
    sed '${./setup-hook.sh}' \
      -e "s,@type@,${type},g" \
      -e "s,@typefx@,${typefx},g" \
      -e "s,@targetfx@,${targetfx},g" \
      >"''${outputs[out]}"/nix-support/setup-hook
  '';

  inherit
    compiler
    tools
    inputs;

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux ++
      x86_64-linux ++
      powerpc64le-linux;
  };
})
