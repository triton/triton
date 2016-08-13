# Add gio modules to GIO_EXTRA_MODULES
find_gio_modules() {
  if [ -d "${1}/lib/gio-modules/$(basename "${1}")/gio/modules" ] ; then
    addToSearchPath GIO_EXTRA_MODULES \
      "${1}/lib/gio-modules/$(basename "${1}")/gio/modules"
  fi
}

# Add gsettings schemas to GSETTINGS_SCHEMAS_PATH
find_gsettings_schemas() {
  if [ -d "${1}/share/gsettings-schemas/$(basename "${1}")/glib-2.0/schemas" ] ; then
    addToSearchPath GSETTINGS_SCHEMAS_PATH \
      "${1}/share/gsettings-schemas/$(basename "${1}")"
  fi
}

# Make sure gio modules are installed in
#   $out/lib/gio-modules/$(basename "${1}")/gio/modules/
fix_gio_modules_install_path() {
  # If gio modules are all installed in $out/lib/gio/modules, it will
  # result in filename collisions with giomodule.cache when trying to
  # add more than one package conatining this file to a given profile.

  # At runtime, glib looks for gio/modules in GIO_EXTRA_MODULES,
  # so we must place these directories in a unique directory.

  if [ -d "${1}/lib/gio/modules" ] ; then
    mkdir -pv "${1}/lib/gio-modules/$(basename "${1}")"
    mv -v \
      "${1}/lib/gio" \
      "${1}/lib/gio-modules/$(basename "${1}")/"
  fi

  addToSearchPath GIO_EXTRA_MODULES "${1}/lib/gio-modules/$(basename "${1}")"
}

# Make sure gsettings schemas are installed in
#   $out/share/gsettings-schemas/$(basename "${1}")/glib-2.0/schemas/
fix_gsettings_schemas_install_path() {
  # If gsettings schemas are all installed in $out/glib-2.0/schemas, it
  # will result in filename collisions with gschemas.compiled when trying
  # to add more than one package conatining this file to a given profile.

  # At runtime, gsettings looks for glib-2.0/schemas in XDG_DATA_DIRS, so
  # we must place these directories in a unique directory.

  if [ -d "${1}/share/glib-2.0/schemas" ] ; then
    mkdir -pv "${1}/share/gsettings-schemas/$(basename "${1}")/glib-2.0"
    mv -v \
      "${1}/share/glib-2.0/schemas" \
      "${1}/share/gsettings-schemas/$(basename "${1}")/glib-2.0/"
  fi

  addToSearchPath GSETTINGS_SCHEMAS_PATH \
    "${1}/share/gsettings-schemas/$(basename "${1}")"
}

# Recompile schemas to make sure all schemas are compiled and to
# ensure gschemas.compiled exists.
fix_compiled_gsettings_schemas() {
  if [ -d "${1}/share/gsettings-schemas/$(basename "${1}")/glib-2.0/schemas" ] ; then
    if type -P glib-compile-schemas ; then
      # Remove existing gschemas.compiled
      if [ -f "${1}/share/gsettings-schemas/$(basename "${1}")/glib-2.0/schemas/gschemas.compiled" ] ; then
        rm -fv "${1}/share/gsettings-schemas/$(basename "${1}")/glib-2.0/schemas/gschemas.compiled"
      fi
      glib-compile-schemas \
        "${1}/share/gsettings-schemas/$(basename "${1}")/glib-2.0/schemas/"
    elif [ -x "${1}/bin/glib-compile-schemas" ] ; then
      # Do not try to compile schemas in glib itself
      :
    else
      echo 'ERROR: fix_compiled_gsettings_schemas failed, glib-compile-schemas'
      echo '       not found in PATH or $out/bin/glib-compile-schemas'
      return 1
    fi
  fi
}

envHooks+=('find_gio_modules')
envHooks+=('find_gsettings_schemas')

installFlagsArray+=(
  "gsettingsschemadir=${out}/share/gsettings-schemas/${name}/glib-2.0/schemas/"
)

preFixupPhases+=('fix_gio_modules_install_path')
preFixupPhases+=('fix_gsettings_schemas_install_path')
preFixupPhases+=('fix_compiled_gsettings_schemas')
