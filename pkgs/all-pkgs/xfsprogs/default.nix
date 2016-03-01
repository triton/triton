{ stdenv
, fetchTritonPatch
, fetchurl
, gettext

, readline
, util-linux_lib
}:

stdenv.mkDerivation rec {
  name = "xfsprogs-4.3.0";

  src = fetchurl {
    urls = map (dir: "ftp://oss.sgi.com/projects/xfs/${dir}/${name}.tar.gz")
      [ "cmd_tars" "previous" ];
    sha256 = "0p6bsh350zf85q8a7sv6s5anpm6vbn02qazlj8vvxr2k27ahlmry";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    readline
    util-linux_lib
  ];

  outputs = [
    "out"
    "lib"
  ];

  prePatch = ''
    sed -i "s,/bin/bash,$(type -P bash),g" install-sh
    sed -i "s,ldconfig,$(type -P ldconfig),g" configure m4/libtool.m4

    # Fixes from gentoo 3.2.1 ebuild
    sed -i "/^PKG_DOC_DIR/s:@pkg_name@:${name}:" include/builddefs.in
    sed -i "/LLDFLAGS.*libtool-libs/d" $(find -name Makefile)
    sed -i '/LIB_SUBDIRS/s:libdisk::' Makefile
  '';

  patches = [
    (fetchTritonPatch {
      rev = "07aa30f6f5e0f4a08903cf93cdc1825d75a81404";
      file = "xfsprogs/xfsprogs-4.3.0-sharedlibs.patch";
      sha256 = "23bf3127cd1eab6e96055d2a5f3ae61f417a8d4ae52d5c421be2bbb05576bb46";
    })
  ];

  preConfigure = ''
    NIX_LDFLAGS="$(echo $NIX_LDFLAGS | sed "s,$out,$lib,g")"
  '';

  configureFlags = [
    "MAKE=make"
    "MSGFMT=msgfmt"
    "MSGMERGE=msgmerge"
    "XGETTEXT=xgettext"
    "--disable-lib64"
    "--enable-readline"
    "--includedir=$(lib)/include"
    "--libdir=$(lib)/lib"
  ];

  installFlags = [
    "install-dev"
  ];

  meta = with stdenv.lib; {
    homepage = http://xfs.org/;
    description = "SGI XFS utilities";
    license = licenses.lgpl21;
    platforms = platforms.linux;
    maintainers = with maintainers; [ wkennington ];
  };
}
