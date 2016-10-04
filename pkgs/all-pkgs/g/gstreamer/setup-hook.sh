addGstreamer1LibPath() {
  if [ -d "${1}/lib/gstreamer-1.0" ] ; then
    GST_PLUGIN_PATH="${GST_PLUGIN_PATH}${GST_PLUGIN_PATH:+:}${1}/lib/gstreamer-1.0"
  fi
}

envHooks+=('addGstreamer1LibPath')
