gnomeWrapperArgs=()

findGioModules() {

  if [[ -d "${1}/lib/gio/modules" && \
        -n "$(ls -A "${1}/lib/gio/modules")" ]] ; then
    gnomeWrapperArgs+=("--prefix GIO_EXTRA_MODULES : ${1}/lib/gio/modules")
  fi

}

wrapGnomeAppsHook() {

  local dummy
  local i
  local v

  if [[ -n "${GDK_PIXBUF_MODULE_FILE}" ]] ; then
    gnomeWrapperArgs+=(
      "--set GDK_PIXBUF_MODULE_FILE ${GDK_PIXBUF_MODULE_FILE}"
    )
  fi

  if [[ -n "${XDG_ICON_DIRS}" ]] ; then
    gnomeWrapperArgs+=("--prefix XDG_DATA_DIRS : ${XDG_ICON_DIRS}")
  fi

  if [[ -n "${GSETTINGS_SCHEMAS_PATH}" ]] ; then
    gnomeWrapperArgs+=("--prefix XDG_DATA_DIRS : ${GSETTINGS_SCHEMAS_PATH}")
  fi

  if [[ -d "${prefix}/share" ]] ; then
    gnomeWrapperArgs+=("--prefix XDG_DATA_DIRS : ${prefix}/share")
  fi

  for v in \
    "${wrapPrefixVariables}" \
    'GST_PLUGIN_SYSTEM_PATH_1_0' \
    'GI_TYPELIB_PATH' \
    'GRL_PLUGIN_PATH' ; do

    if [[ -z "${v}" ]] ; then
      continue
    fi

    eval dummy="\$${v}"

    if [[ -z "${dummy}" ]] ; then
      continue
    fi

    gnomeWrapperArgs+=("--prefix ${v} : ${dummy}")
  done

  if test -z "${disableGnomeWrapper}" && \
     [[ -n "${gnomeWrapperArgs[@]}" ]] ; then
    for i in \
      "${prefix}/bin/"* \
      "${prefix}/libexec/"* ; do
      echo "Wrapping GNOME app ${i}"
      wrapProgram "${i}" ${gnomeWrapperArgs[@]}
    done
  fi

}

envHooks+=('findGioModules')
fixupOutputHooks+=('wrapGnomeAppsHook')
