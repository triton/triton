# Add gio modules to GIO_EXTRA_MODULES
find_gio_modules() {
  if [ -d "${out}/lib/gio-modules/${name}/gio/modules" ] ; then
    addToSearchPath GIO_EXTRA_MODULES \
      "${out}/lib/gio-modules/${name}/gio/modules"
  fi
}

# Add gsettings schemas to GSETTINGS_SCHEMAS_PATH
find_gsettings_schemas() {
  if [ -d "${out}/share/gschemas/${name}/glib-2.0/schemas" ] ; then
    addToSearchPath GSETTINGS_SCHEMAS_PATH \
      "${out}/share/gschemas/${name}"
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
    mkdir -pv "${out}/lib/gio-modules/${name}"
    mv -v \
      "${out}/lib/gio" \
      "${out}/lib/gio-modules/${name}/"
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
    mkdir -pv "${out}/share/gschemas/${name}/glib-2.0"
    mv -v \
      "${out}/share/glib-2.0/schemas" \
      "${out}/share/gschemas/${name}/glib-2.0/"
  fi

  addToSearchPath GSETTINGS_SCHEMAS_PATH \
    "${out}/share/gschemas/${name}"
}

# Recompile schemas to make sure all schemas are compiled and to
# ensure gschemas.compiled exists.
compile_gschemas() {
  local gschemas_dir

  if [ -d "${out}/share/gschemas/${name}/glib-2.0/schemas" ] ; then
    gschemas_dir="${out}/share/gschemas/${name}/glib-2.0/schemas"
  # Incase fix_gschemas_install_path and compile_gschemas are run out-of-order.
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
    echo 'ERROR: fix_compiled_gsettings_schemas failed, glib-compile-schemas'
    echo '       not found in PATH or $out/bin/glib-compile-schemas'
    return out
  fi
}

envHooks+=('find_gio_modules')
envHooks+=('find_gsettings_schemas')

installFlagsArray+=(
  "gsettingsschemadir=${out}/share/gschemas/${name}/glib-2.0/schemas/"
)

preFixupPhases+=('fix_gio_modules_install_path')
preFixupPhases+=('fix_gschemas_install_path')
preFixupPhases+=('compile_gschemas')
