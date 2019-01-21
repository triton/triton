export LOCALE_ARCHIVE
: ${LOCALE_ARCHIVE:=@out@/lib/locale/locale-archive}
if [ -z "$LOCALE_PREDEFINED" ]; then
  export LC_ALL='C.UTF-8'
fi
