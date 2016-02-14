{ stdenv
, fetchTritonPatch
, fetchurl

, glib
, gobject-introspection
, vala
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "libgee-${version}";
  versionMajor = "0.18";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/libgee/${versionMajor}/${name}.tar.xz";
    sha256 = "16a34js81w9m2bw4qd8csm4pcgr3zq5z87867j4b8wfh6zwrxnaa";
  };

  buildInputs = [
    glib
    gobject-introspection
    vala
  ];

  patches = [
    (fetchTritonPatch {
      rev = "734f89c9d36781e3f50f30dc9aa33d071136dbd0";
      file = "libgee/fix_introspection_paths.patch";
      sha256 = "4164fb22b29a9dac7b6940bbb848a4d1fcb8cc81b207db7d69d7ab67c4aa4aed";
    })
  ];

  configureFlags = [
    "--disable-doc"
    "--disable-coverage"
    "--disable-benchmark"
    "--enable-internal-asserts"
    "--disable-consisteency-checks"
    (enFlag "introspection" (gobject-introspection != null) null)
    (enFlag "vala" (vala != null) null)
    "--disable-vala-fatal-warnings"
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "GObject-based interfaces and classes for common data structures";
    homepage = https://wiki.gnome.org/Projects/Libgee;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
