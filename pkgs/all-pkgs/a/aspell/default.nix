{ stdenv
, fetchurl
, lib
, perl
}:

stdenv.mkDerivation rec {
  name = "aspell-0.60.6.1";

  src = fetchurl {
    url = "mirror://gnu/aspell/${name}.tar.gz";
    sha256 = "1qgn5psfyhbrnap275xjfrzppf5a83fb67gpql0kfqv37al869gm";
  };

  nativeBuildInputs = [
    perl
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--enable-pkglibdir=$out/lib/aspell"
      "--enable-pkgdatadir=$out/lib/aspell"
    );
  '';

  CXXFLAGS = "-fpermissive";

  # Note: Users should define the `ASPELL_CONF' environment variable to
  # `data-dir $HOME/.nix-profile/lib/aspell/' so that they can access
  # dictionaries installed in their profile.
  #
  # We can't use `$out/etc/aspell.conf' for that purpose since Aspell
  # doesn't expand environment variables such as `$HOME'.

  # Parallel building is horribly broken
  buildParallel = false;
  installParallel = false;

  meta = with lib; {
    description = "Spell checker for many languages";
    homepage = http://aspell.net/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
