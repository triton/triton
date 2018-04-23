{ stdenv
, autoreconfHook
, fetchFromGitHub
, isPy3
, lib
, pkgconfig
, wrapPython

, atk
, glib
, gtk_2
, libglade
, pango
, pygobject_2
, pycairo
, python
}:

# Pygtk is not compatible with Python 3.x
assert !isPy3;

stdenv.mkDerivation rec {
  name = "pygtk-2.24-2011-10-02";

  src = fetchFromGitHub {
    version = 6;
    owner = "GNOME";
    repo = "pygtk";
    rev = "eaf1c1b881d2d20d202cf475b5ffed2206b110df";
    sha256 = "3393309ec2cd452c598b86fdddfce1f9de5aa02a8044b74bdaab1e43dd6fa462";
  };

  nativeBuildInputs = [
    autoreconfHook  # Just used to include all dependencies
  ];

  propagatedBuildInputs = [
    atk
    glib
    gtk_2
    libglade
    pango
    pycairo
    pygobject_2
    python
    wrapPython
  ];

  postPatch = ''
    sed -i configure.ac \
      -e 's/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/'
  '';

  autoreconfPhase = ''
    # autoreconfHook doesn't use $ACLOCAL_FLAGS so it must be run manually
    aclocal --force -I m4/
    libtoolize --copy --force
    autoheader
    automake --force-missing --add-missing
    autoconf --force
  '';

  postInstall = ''
    rm -v $out/bin/pygtk-codegen-2.0
    ln -sv \
      ${pygobject_2}/bin/pygobject-codegen-2.0  \
      $out/bin/pygtk-codegen-2.0
    ln -sv \
      ${pygobject_2}/lib/${python.libPrefix}/site-packages/${pygobject_2.name}.pth \
      $out/lib/${python.libPrefix}/site-packages/${name}.pth
  '';

  preCheck = ''
    sed -i tests/common.py \
      -e "s/glade = importModule('gtk.glade', buildDir)//" \
      -e "s/sys.path.insert(0, os.path.join(buildDir, 'gtk'))//" \
      -e "s/sys.path.insert(0, buildDir)//"

    sed -i tests/test_api.py \
      -e "s/, glade$//" \
      -e "s/.*testGlade.*//" \
      -e "s/.*(glade.*//"
  '';

  # XXX: TypeError: Unsupported type: <class 'gtk._gtk.WindowType'>
  doCheck = false;

  meta = with lib; {
    description = "GTK+2 bindings for Python";
    homepage = http://www.pygtk.org/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
