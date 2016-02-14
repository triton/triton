{ stdenv
, fetchTritonPatch
, fetchurl

, atkmm
, cairomm
, glibmm
, gtk2
, pangomm
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "gtkmm-${version}";
  versionMajor = "2.24";
  versionMinor = "4";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gtkmm/${versionMajor}/${name}.tar.xz";
    sha256 = "1vpmjqv0aqb1ds0xi6nigxnhlr0c74090xzi15b92amlzkrjyfj4";
  };

  patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "gtkmm/gtkmm-2.24.4-papersize.patch";
      sha256 = "18d47169814e0ab6a9a085a9803679a6aff95fb574c33a3f1547fb8fc25d0dcf";
    })
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "gtkmm/gtkmm-2.24.4-missing-includes.patch";
      sha256 = "cdb33a7de66bed0086a794521681a4521e8761440339d182695784dbf7cbf0b1";
    })
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "gtkmm/gtkmm-2.24.4-newer-glibmm.patch";
      sha256 = "f6f93c53f98adf44ded91c0a9289b0fdf1c0dbd4f36aaa7a0efa20fdd7a2b408";
    })
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "gtkmm/gtkmm-2.24.4-add-list.m4.patch";
      sha256 = "568214783ebfc13e4e7b6dd5baf9934c36ae8dc84682c0cdbc80c033db344d4e";
    })
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "gtkmm/gtkmm-2.24.4-fix-add-list.m4.patch";
      sha256 = "c4dcf122a19395e36d8c1a218434da1aa03809dac2036d4ffa7559605672ca4c";
    })
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "gtkmm/gtkmm-2.24.4-cpp11.patch";
      sha256 = "5e80a44080b8d34a2f1b9ec6d15c23f18a314ad61ff94cfa1305a5a0bd845c0c";
    })
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "gtkmm/gtkmm-2.24.4-gdkpixbud-deprecation-warnings.patch";
      sha256 = "aae4777a8d9dacf15d3f90d2df28f92b64a1ad646a94665623d1538fa8f79fb3";
    })
  ];

  configureFlags = [
    (enFlag "api-atkmm" (atkmm != null) null)
    # Nokia maemo
    (enFlag "api-maemo-extensions" true null)
    # Requires deprecated api
    "--enable-deprecated-api"
    "--disable-documentation"
    "--without-libstdc-doc"
    "--without-libsigc-doc"
    "--without-glibmm-doc"
    "--without-cairomm-doc"
    "--without-pangomm-doc"
    "--without-atkmm-doc"
  ];

  buildInputs = [
    atkmm
    cairomm
    glibmm
    gtk2
    pangomm
  ];

  doCheck = true;
  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "C++ interface for GTK+";
    homepage = http://gtkmm.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
