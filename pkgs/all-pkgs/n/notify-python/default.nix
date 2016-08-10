{ stdenv
, buildPythonPackage
, fetchTritonPatch
, fetchurl

, pkgs
, pythonPackages
}:

stdenv.mkDerivation rec {
  name = "notify-python-0.1.1";

  src = fetchurl {
    url = "http://www.galago-project.org/files/releases/source/notify-python/"
      + "${name}.tar.bz2";
    sha256 = "7d3bbb7c3d8f56c922cc31d02ef9057a4f06998cc2fd4f3119a576fcf8d504ce";
  };

  buildInputs = [
    pkgs.libnotify
    pythonPackages.pygtk
    pythonPackages.python
  ];

  patches = [
    (fetchTritonPatch {
      rev = "44001868689137b1caf38c410f411c0434b20eb0";
      file = "notify-python/notify-python-0.1.1-libnotify-0.7.patch";
      sha256 = "2ced9909d30f0873ea5b048d65552b02e846beeb09346555e2271e42613d9028";
    })
  ];

  postPatch = ''
    # Remove the old pynotify.c to ensure it's properly regenerated, gentoo:#212128.
    rm -fv src/pynotify.c

    sed -i configure \
      -e '/^PYGTK_CODEGEN/s|=.*|="${pythonPackages.pygtk}/bin/pygtk-codegen-2.0"|'
  '';

  postInstall = ''
    pushd $out/lib/python*/site-packages
      ln -s gtk-*/pynotify .
    popd
  '';


  meta = with stdenv.lib; {
    description = "Python bindings for libnotify";
    homepage = http://www.galago-project.org/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
