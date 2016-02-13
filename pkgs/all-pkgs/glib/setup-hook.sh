find_gio_modules() {

  # Add glib modules to GIO_EXTRA_MODULES

  if [[ -d "${1}/lib/gio/modules" ]] ; then
    addToSearchPath 'GIO_EXTRA_MODULES' "${1}/lib/gio/modules"
  fi

}

find_gsettings_schemas() {

  # Add glib schemas to GSETTINGS_SCHEMAS_PATH

  if [[ -d "${1}/share/gsettings-schemas/"*"/glib-2.0/schemas" ]] ; then
    addToSearchPath 'GSETTINGS_SCHEMAS_PATH' \
      "${1}/share/gsettings-schemas/"*
  fi

}

glibPreFixupPhase() {

  # Make sure schemas are installed in
  #   $out/gsettings-schemas/${name}/glib-2.0/schemas/

  # If schemas are all installed in $out/glib-2.0/schemas, it will
  # result in filename collisions with gschemas.compiled when trying to
  # add more than one package conatining this file to a given profile.

  # At runtime, gsettings looks for glib-2.0/schemas in XDG_DATA_DIRS, so
  # we must place these directories in a unique directory

  if [[ -d "${out}/share/glib-2.0/schemas" ]] ; then
    mkdir -pv "${out}/share/gsettings-schemas/${name}/glib-2.0/schemas/"
    mv -v \
      "${out}/share/glib-2.0/schemas" \
      "${out}/share/gsettings-schemas/${name}/glib-2.0/schemas"
  fi

  addToSearchPath 'GSETTINGS_SCHEMAS_PATH' \
    "${out}/share/gsettings-schemas/${name}"

}

envHooks+=(
  'find_gio_modules'
  'find_gsettings_schemas'
)

installFlagsArray+=(
  "gsettingsschemadir=${out}/share/gsettings-schemas/${name}/glib-2.0/schemas/"
)

preFixupPhases+=(
  'glibPreFixupPhase'
)
