findGdkPixbufLoaders() {
  export GDK_PIXBUF_MODULE_FILE="@out@/$loadersCachePath"
}

envHooks+=('findGdkPixbufLoaders')
