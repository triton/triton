{ stdenv
, cmake
, fetchurl
, ninja
, perl
, vala

, db
, glib
, gobject-introspection
, icu
, libxml2
}:

let
  version = "3.0.4";
in
stdenv.mkDerivation rec {
  name = "libical-${version}";

  src = fetchurl {
    url = "https://github.com/libical/libical/releases/download/v${version}/${name}.tar.gz";
    sha256 = "72b216e10233c3f60cb06062facf41f3b0f70615e5a60b47f9853341a0d5d145";
  };

  nativeBuildInputs = [
    cmake
    ninja
    perl
    vala
  ];

  buildInputs = [
    db
    glib
    gobject-introspection
    icu
    libxml2
  ];

  cmakeFlags = [
    "-DSHARED_ONLY=YES"
    "-DUSE_BUILTIN_TZDATA=NO"
    "-DGOBJECT_INTROSPECTION=YES"
    "-DICAL_BUILD_DOCS=NO"
    "-DICAL_GLIB_VAPI=YES"
    "-DICAL_GLIB=YES"
  ];

  # Remove this when makeFlags and ninjaFlags are separate
  setVapidirInstallFlag = false;

  meta = with stdenv.lib; {
    homepage = https://github.com/libical/libical;
    description = "an Open Source implementation of the iCalendar protocols";
    license = licenses.mpl10;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
