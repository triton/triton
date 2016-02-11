find_gio_modules() {

  # Add glib modules to GIO_EXTRA_MODULES

  if [[ -d "${1}/lib/gio/modules" ]] ; then
    addToSearchPath 'GIO_EXTRA_MODULES' "${1}/lib/gio/modules")
  fi

}

find_gsettings_schemas() {

  # Add glib schemas to GSETTINGS_SCHEMAS_PATH

  if [[ -d "${1}/share/glib-2.0/schemas" ]] ; then
    addToSearchPath 'GSETTINGS_SCHEMAS_PATH' "${1}/share"
  fi

}

glibPreFixupPhase() {

  # Make sure schemas are installed in $out/share/glib-2.0/schemas

  if [[ -d "${out}/share/gsettings-schemas/${name}/glib-2.0/schemas" ]] ; then
    mkdir -pv "${out}/share/glib-2.0/schemas"
    mv -v \
      "${out}/share/gsettings-schemas/${name}/glib-2.0/schemas" \
      "${out}/share/glib-2.0/schemas"
  fi

  addToSearchPath 'GSETTINGS_SCHEMAS_PATH' "${out}/share"

}

envHooks+=(
  'find_gio_modules'
  'find_gsettings_schemas'
)

installFlagsArray+=(
  "gsettingsschemadir=${out}/share/glib-2.0/schemas/"
)

preFixupPhases+=(
  'glibPreFixupPhase'
)
