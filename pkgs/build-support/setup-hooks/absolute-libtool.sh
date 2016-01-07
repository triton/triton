# This setup hook creates absolute references to library files in the fixup phase.

fixupOutputHooks+=(_doAbsoluteLibtool)

_doAbsoluteLibtool() {
  if [ -n "$dontAbsoluteLibtool" ]; then
    return
  fi
  header "Fixing up library paths"
  buildAbsoluteLdflags
  patchLaFiles
  patchPcFiles
  stopNest
}

buildAbsoluteLdflags() {
  if [ -e "$TMPDIR/absolute-lib-paths" ]; then
    return 0
  fi
  echo "$LDFLAGS $NIX_LDFLAGS" > $TMPDIR/absolute-ldflags

  # Add the outputs to the LDFLAGS
  local output
  for output in $outputs; do
    echo "-L${!output}/lib" >> $TMPDIR/absolute-ldflags

    # Get the paths to ldflags in .la files
    local LA_FILES
    LA_FILES=$(find ${!output}/lib -name \*.la 2>/dev/null || true)
    local FILE
    for FILE in $LA_FILES; do
      grep '^dependency_libs=' $FILE | sed "s,^dependency_libs='\(.*\)',\1,g" >> $TMPDIR/absolute-ldflags
    done

    # Get the paths to ldflags in .pc files
    local PC_FILES
    PC_FILES=$(find ${!output}/lib/pkgconfig -name \*.pc 2>/dev/null || true)
    local FILE
    for FILE in $PC_FILES; do
      pkg-config --libs-only-L --static $FILE >> $TMPDIR/absolute-ldflags
    done
  done

  # Get the paths to the ldflags files in the cc-wrapper
  local LDFLAGS_FILES
  LDFLAGS_FILES=$(dirname $(type -P cc))/../nix-support/*-ldflags

  # Add them to the LDFLAGS variable
  local FILE
  for FILE in $LDFLAGS_FILES; do
   cat $FILE >> $TMPDIR/absolute-ldflags
  done

  # Parse the file down into only the needed paths
  awk '
  BEGIN {
    split("", lib_paths);
    is_rpath = 0;
    FS="[ \t\r\n]+"
  }
  {
    # Parse each of the library paths
    for (i = 1; i <= NF; i++) {
      if (is_rpath) {
        lib_paths[$i] = 1;
        is_rpath = 0;
      } else if ($i ~ /^-rpath$/) {
        is_rpath = 1;
      } else if ($i ~ /^-L/) {
        lib_paths[substr($i, 3, length($i)-2)] = 1;
      }
    }
  }
  END {
    # Remove the blacklisted paths
    split(ENVIRON["ABSOLUTE_LIBTOOL_EXCLUDED"], split_excluded_paths, "[ \t\n:]+")
    for (i in split_excluded_paths) {
      print "Exclude Path:" split_excluded_paths[i] > "/dev/stderr";
      delete lib_paths[split_excluded_paths[i]];
    }

    # Print the final output
    for (lib_path in lib_paths) {
      #if (system("test -d " lib_path) == 0) {
        print lib_path;
      #}
    }
  }
  ' $TMPDIR/absolute-ldflags > $TMPDIR/absolute-lib-paths
  du -bhs $TMPDIR/absolute-ldflags
  rm $TMPDIR/absolute-ldflags
}

patchLaFiles() {
  local LA_FILES
  LA_FILES=$(find ${!output}/lib -name \*.la 2>/dev/null || true)
  local FILE
  for FILE in $LA_FILES; do
    echo "Patching Library Paths: $FILE" >&2
    cat "$FILE" | awkReplacer > "$FILE".tmp
    mv "$FILE".tmp "$FILE"
  done
}

patchPcFiles() {
  local PC_FILES
  PC_FILES=$(find ${!output}/lib/pkgconfig -name \*.pc 2>/dev/null || true)
  local FILE
  for FILE in $PC_FILES; do
    echo "Patching Library Paths: $FILE" >&2
    readPcFile "$FILE" | awkReplacer > "$FILE".tmp
    mv "$FILE".tmp "$FILE"
  done
}

readPcFile() {
  cp "$1" "$1".tmp2
  sed -i '/Requires\(\|.private\):/d' "$1"
  local LIBS; local LIBS_COMBINED; local LIBS_PRIVATE
  LIBS="$(pkg-config --libs "$1")"
  LIBS_COMBINED="$(pkg-config --libs --static "$1")"
  LIBS_PRIVATE="$(echo "$LIBS" "$LIBS_COMBINED" | tr ' ' '\n' | sort | uniq -u | tr '\n' ' ')"
  mv "$1".tmp2 "$1"
  sed "$1" \
    -e "s@^Libs:.*\$@Libs: $LIBS@g" \
    -e "s@^Libs.private:.*\$@Libs.private: $LIBS_PRIVATE@g"
}

# Pipe the libtool command line to be fixed
awkReplacer() {
  awk -f <(cat << 'EOF'
BEGIN {
  split("", lib_paths);
  lib_paths_file = ENVIRON["TMPDIR"] "/absolute-lib-paths";
  while (getline line < lib_paths_file) {
    lib_paths[line] = 1;
  }
  close(lib_paths_file);
}
function getFullLibPath(lib_path, lib,    file) {
  # A hack for the case where -lgcc referes to libgcc_s.so
  if (lib == "gcc") {
    file = lib_path "/libgcc_s.so";
  } else {
    file = lib_path "/lib" lib ".so";
  }
  if (system("test -e " file) == 0) {
    return file;
  }
  file = lib_path "/lib" lib ".a";
  if (system("test -e " file) == 0) {
    return file;
  }
  return 0;
}
function replaceStmt(stmt,    matches, file, output, lib_path) {
  if (stmt ~ /^-L/) {
    return "";
  } else if (match(stmt, /^-l(.*)$/, matches)) {
    for (lib_path in lib_paths) {
      file = getFullLibPath(lib_path, matches[1]);
      if (!file) {
        continue;
      }
      output = "";
      if (!printed_path[lib_path]) {
        output = output "-L" lib_path " ";
        printed_path[lib_path] = 1;
      }
      output = output "-l" matches[1];
      return output;
    }
    print "Failed to find a path for: lib" matches[1] > "/dev/stderr"
    exit 1;
  } else {
    return stmt;
  }
}
{
  split("", printed_path);

  if (match($0, /^dependency_libs='(.*)'$/, matches)) {
    split(matches[1], split_dependencies, "[ \t]+");
    output = "dependency_libs='";
    for (i in split_dependencies) {
      replacement = replaceStmt(split_dependencies[i]);
      if (replacement != "") {
        output = output " " replacement;
      }
    }
    output = output "'";
    print output;
  } else if (match($0, /^Libs:(.*)$/, matches)) {
    split(matches[1], split_dependencies, "[ \t]+");
    output = "Libs:";
    for (i in split_dependencies) {
      replacement = replaceStmt(split_dependencies[i]);
      if (replacement != "") {
        output = output " " replacement;
      }
    }
    print output;
  } else if (match($0, /^Libs.private:(.*)$/, matches)) {
    split(matches[1], split_dependencies, "[ \t]+");
    output = "Libs.private:";
    for (i in split_dependencies) {
      replacement = replaceStmt(split_dependencies[i]);
      if (replacement != "") {
        output = output " " replacement;
      }
    }
    print output;
  } else {
    print $0;
  }
}
EOF
)
}
