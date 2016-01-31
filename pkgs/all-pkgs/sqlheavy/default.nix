{ stdenv
, autoreconfHook
, fetchFromGitHub

, glib
, gobject-introspection
, sqlite
, vala
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "sqlheavy-${version}";
  version = "2015-06-13";

  src = fetchFromGitHub {
    owner = "chlorm-forks";
    repo = "sqlheavy";
    rev = "e83b497a9528e455baf77c9221041d9e600ea972";
    sha256 = "1nyqkbgx2i86b453k8yb0n2c1s3szs8lysgxkk9n634avms8dyp5";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    glib
    gobject-introspection
    sqlite
    vala
  ];

  preAutoreconf = ''
    touch ChangeLog
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-valadoc"
  ];

  makeFlags = [
    "INTROSPECTION_GIRDIR=$(out)/share/gir-1.0"
    "INTROSPECTION_TYPELIBDIR=$(out)/lib/girepository-1.0"
  ];

  meta = with stdenv.lib; {
    description = "Wrapper on top of SQLite with a GObject-based interface";
    homepage = https://github.com/chlorm-forks/sqlheavy;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
