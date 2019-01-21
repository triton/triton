{ stdenv
, fetchurl
, fetchTritonPatch
, lib

, glibc

, locales ? "glibc"
}:

let
  inherit (glibc)
    version;

  inherit (lib)
    concatStringsSep
    optionals;

  glibcSet = locales == "glibc";
  cOnly = locales == [ "C.UTF-8/UTF-8" ];
in
stdenv.mkDerivation rec {
  name = "glibc-locales-${version}";

  # Prevent preloading the wrong locale-archive
  LC_ALL = "C";

  nativeBuildInputs = [
    glibc
  ];

  buildCommand = ''
    export LOCALE_ARCHIVE="$out"/lib/locale/locale-archive
    mkdir -p "$(dirname "$LOCALE_ARCHIVE")"
  '' + (if cOnly then ''
    ln -sv '${glibc}'/lib/locale/locale-archive "$LOCALE_ARCHIVE"
    test 'C.utf8' = "$(localedef --list-archive "$LOCALE_ARCHIVE")"
  '' else (if glibcSet then ''
    tar --wildcards -xf '${glibc.src}' 'glibc-*/localedata/SUPPORTED'
    echo "include $(echo glibc-*/localedata/SUPPORTED)" >>Makefile
    echo 'print-%: ; @echo $($*)' >>Makefile
    for locale in $(make print-SUPPORTED-LOCALES); do
  '' else ''
    for locale in ${concatStringsSep " " locales}; do
  '') + ''
      charmap="$(echo "$locale" | sed 's,[./].*,,')"
      encoding="$(echo "$locale" | sed 's,.*/,,')"
      full="$(echo "$locale" | sed 's,/.*,,')"
      echo "Building $full"
      localedef -i $charmap -f $encoding $full
    done
  '') + ''
    test "$(localedef --list-archive)" = "$(localedef --list-archive "$LOCALE_ARCHIVE")"
  '';

  setupHook = ./locale-hook.sh;

  # We can't have references to any of our bootstrapping derivations
  allowedReferences = [ "out" ] ++ optionals cOnly [ glibc ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
    priority = -1;  # Should be higher than glibc itself
  };
}
