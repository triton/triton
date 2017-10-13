findGdkPixbufLoaders() {
  export GDK_PIXBUF_MODULE_FILE="@out@/@loadersCache@"
}

envHooks+=('findGdkPixbufLoaders')
