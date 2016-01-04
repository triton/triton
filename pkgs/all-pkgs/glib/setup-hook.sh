# Install gschemas, if any, in a package-specific directory

make_glib_find_gsettings_schemas() {

  # For packages that need gschemas of other packages (e.g. empathy)
  if [[ -d "${1}/share/gsettings-schemas/"*"/glib-2.0/schemas" ]] ; then
    addToSearchPath GSETTINGS_SCHEMAS_PATH "${1}/share/gsettings-schemas/"*
  fi

}


glibPreFixupPhase() {

  # Move gschemas in case the install flag didn't help
  if [[ -d "${out}/share/glib-2.0/schemas" ]] ; then
    mkdir -pv "${out}/share/gsettings-schemas/${name}/glib-2.0"
    mv -v "${out}/share/glib-2.0/schemas" "${out}/share/gsettings-schemas/${name}/glib-2.0/"
  fi

  addToSearchPath GSETTINGS_SCHEMAS_PATH "${out}/share/gsettings-schemas/${name}"

}

envHooks+=('make_glib_find_gsettings_schemas')
installFlagsArray+=("gsettingsschemadir=${out}/share/gsettings-schemas/$name/glib-2.0/schemas/")
preFixupPhases+=" glibPreFixupPhase"
