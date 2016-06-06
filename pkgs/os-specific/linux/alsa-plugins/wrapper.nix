{ writeScriptBin, stdenv, alsa-plugins }:
writeScriptBin "ap${if stdenv.system == "i686-linux" then "32" else "64"}" ''
  #/bin/sh
  ALSA_PLUGIN_DIRS=${alsa-plugins}/lib/alsa-lib "$@"
''
