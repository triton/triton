{ stdenv
, fetchurl
, isPy3k
, lib

, atk
, glib
, gtk_2
, libglade
, pango
, python2Packages
#, pygobject
#, pycairo
}:

stdenv.mkDerivation rec {
  name = "pygtk-2.24.0";

  src = fetchurl {
    url = "mirror://gnome/sources/pygtk/2.24/${name}.tar.bz2";
    sha256 = "04k942gn8vl95kwf0qskkv6npclfm31d78ljkrkgyqxxcni1w76d";
  };

  propagatedBuildInputs = [
    atk
    glib
    gtk_2
    libglade
    pango
    #python2Packages.numpy
    python2Packages.pycairo
    python2Packages.pygobject_2
    python2Packages.python
    python2Packages.wrapPython
  ];

  postInstall = ''
    rm -v $out/bin/pygtk-codegen-2.0
    ln -sv \
      ${python2Packages.pygobject_2}/bin/pygobject-codegen-2.0  \
      $out/bin/pygtk-codegen-2.0
    ln -sv \
      ${python2Packages.pygobject_2}/lib/${python2Packages.python.libPrefix}/site-packages/${python2Packages.pygobject_2.name}.pth \
      $out/lib/${python2Packages.python.libPrefix}/site-packages/${name}.pth
  '';

  checkPhase = ''
    sed -i tests/common.py \
      -e "s/glade = importModule('gtk.glade', buildDir)//" \
      -e "s/sys.path.insert(0, os.path.join(buildDir, 'gtk'))//" \
      -e "s/sys.path.insert(0, buildDir)//"

    sed -i tests/test_api.py \
      -e "s/, glade$//" \
      -e "s/.*testGlade.*//" \
      -e "s/.*(glade.*//"

    make check
  '';

  # XXX: TypeError: Unsupported type: <class 'gtk._gtk.WindowType'>
  # The check phase was not executed in the previous
  # non-buildPythonPackage setup - not sure why not.
  doCheck = false;

  disabled = isPy3k;

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
