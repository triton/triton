# Add gio modules to GIO_EXTRA_MODULES
find_gio_modules() {
  if [ -d "${1}/lib/gio-modules/"*"/gio/modules" ] ; then
    addToSearchPath GIO_EXTRA_MODULES \
      "${1}/lib/gio-modules/"*"/gio/modules"
  fi
}

# Add gsettings schemas to GSETTINGS_SCHEMAS_PATH
find_gsettings_schemas() {
  if [ -d "${1}/share/gschemas/"*"/glib-2.0/schemas" ] ; then
    addToSearchPath GSETTINGS_SCHEMAS_PATH \
      "${1}/share/gschemas/"*
  fi
}

# Make sure gio modules are installed in
#   $out/lib/gio-modules/${name}/gio/modules/
fix_gio_modules_install_path() {
  # If gio modules are all installed in $out/lib/gio/modules, it will
  # result in filename collisions with giomodule.cache when trying to
  # add more than one package conatining this file to a given profile.

  # At runtime, glib looks for gio/modules in GIO_EXTRA_MODULES,
  # so we must place these directories in a unique directory.

  if [ -d "${out}/lib/gio/modules" ] ; then
    # Ignore empty directories
    if [ "$(ls -A "${out}/lib/gio/modules")" ] ; then
      mkdir -pv "${out}/lib/gio-modules/${name}"
      mv -v \
        "${out}/lib/gio" \
        "${out}/lib/gio-modules/${name}/"
    fi
    # If the directory is empty after moving files remove it.
    if [ ! "$(ls -A "${out}/lib/gio/modules")" ] ; then
      rm -rvf "${out}/lib/gio/modules"
      if [ ! "$(ls -A "${out}/lib/gio")" ] ; then
        rm -rvf "${out}/lib/gio"
      fi
    fi
  fi

  addToSearchPath GIO_EXTRA_MODULES \
    "${out}/lib/gio-modules/${name}"
}

# Make sure gsettings schemas are installed in
#   $out/share/gschemas/${name}/glib-2.0/schemas/
fix_gschemas_install_path() {
  # If gsettings schemas are all installed in $out/glib-2.0/schemas, it
  # will result in filename collisions with gschemas.compiled when trying
  # to add more than one package conatining this file to a given profile.

  # At runtime, gsettings looks for glib-2.0/schemas in XDG_DATA_DIRS, so
  # we must place these directories in a unique directory.

  if [ -d "${out}/share/glib-2.0/schemas" ] ; then
    # Ignore empty directories
    if [ "$(ls -A "${out}/share/glib-2.0/schemas")" ] ; then
      mkdir -pv "${out}/share/gschemas/${name}/glib-2.0"
      mv -v \
        "${out}/share/glib-2.0/schemas" \
        "${out}/share/gschemas/${name}/glib-2.0/"
    fi
    # If the directory is empty after moving files remove it.
    if [ ! "$(ls -A "${out}/share/glib-2.0/schemas")" ] ; then
      rm -rvf "${out}/share/glib-2.0/schemas"
      if [ ! "$(ls -A "${out}/share/glib-2.0")" ] ; then
        rm -rvf "${out}/share/glib-2.0"
      fi
    fi
  fi

  addToSearchPath GSETTINGS_SCHEMAS_PATH \
    "${out}/share/gschemas/${name}"
}

# Recache gio modules to ensure all modules are cached and that
# giomodule.cache exists.
cache_gio_modules() {
  local giomodulesdir

  if [ -d "${out}/lib/gio-modules/${name}/gio/modules" ] ; then
    giomodulesdir="${out}/lib/gio-modules/${name}/gio/modules"
  # Incase fix_gio_modules_install_path and compile_gschemas are
  # run out-of-order.
  elif [ -d "${out}/lib/gio/modules" ] ; then
    giomodulesdir="${out}/lib/gio/modules"
  else
    return 0
  fi

  echo "Caching gio modules in: ${giomodulesdir}"
  if [ -x "${out}/bin/gio-querymodules" ] ; then
    # Do not try to cache gio modules in glib itself
    :
  elif type -P gio-querymodules ; then
    # Remove existing gschemas.compiled
    if [ -f "${giomodulesdir}/giomodule.cache" ] ; then
      rm -fv "${giomodulesdir}/giomodule.cache"
    fi
    gio-querymodules "${giomodulesdir}/"
  else
    echo 'ERROR: cache_gio_modules failed, gio-querymodules not'
    echo '       found in PATH or $out/bin/gio-querymodules'
    return 1
  fi
}

# Recompile schemas to ensure all schemas are compiled and that
# gschemas.compiled exists.
compile_gschemas() {
  local gschemas_dir

  if [ -d "${out}/share/gschemas/${name}/glib-2.0/schemas" ] ; then
    gschemas_dir="${out}/share/gschemas/${name}/glib-2.0/schemas"
  # Incase fix_gschemas_install_path and compile_gschemas are
  # run out-of-order.
  elif [ -d "${out}/share/glib-2.0/schemas" ] ; then
    gschemas_dir="${out}/share/glib-2.0/schemas"
  # If no gschemas directories exists exit hook.
  else
    return 0
  fi

  echo "Compiling gschemas in: ${gschemas_dir}"
  if [ -x "${out}/bin/glib-compile-schemas" ] ; then
    # Do not try to compile schemas in glib itself
    :
  elif type -P glib-compile-schemas ; then
    # Remove existing gschemas.compiled
    if [ -f "${gschemas_dir}/gschemas.compiled" ] ; then
      rm -fv "${gschemas_dir}/gschemas.compiled"
    fi
    glib-compile-schemas "${gschemas_dir}/"
  else
    echo 'ERROR: compile_gschemas failed, glib-compile-schemas not'
    echo '       found in PATH or $out/bin/glib-compile-schemas'
    return 1
  fi
}

set_gsettingschemadir() {
  # Only add installFlags if we are using the default `make install` process
  if [ -z "$installPhase" ]; then
    installFlagsArray+=(
      "gsettingsschemadir=${out}/share/gschemas/${name}/glib-2.0/schemas/"
    )
  fi
}

envHooks+=('find_gio_modules')
envHooks+=('find_gsettings_schemas')

preInstallPhases+=('set_gsettingschemadir')

preFixupPhases+=('fix_gio_modules_install_path')
preFixupPhases+=('fix_gschemas_install_path')
preFixupPhases+=('cache_gio_modules')
preFixupPhases+=('compile_gschemas')
