{ stdenv
, fetchurl
, gettext

, ncurses
, pcre2_lib
, python3
}:

let
  version = "3.0.0";
in
stdenv.mkDerivation rec {
  name = "fish-${version}";

  src = fetchurl {
    url = "https://github.com/fish-shell/fish-shell/releases/download/${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "ea9dd3614bb0346829ce7319437c6a93e3e1dfde3b7f6a469b543b0d2c68f2cf";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    ncurses
    pcre2_lib
  ];

  postPatch = ''
    # Hack around building the version file from the git tree
    echo "FISH_BUILD_VERSION = '${version}'" >FISH-BUILD-VERSION-FILE
    sed -i 's,^FISH-BUILD-VERSION-FILE:.*$,FISH-BUILD-VERSION-FILE:,' Makefile.in
  '';

  configureFlags = [
    "--without-included-pcre2"
  ];

  preFixup = ''
    sed -i 's,\(^\|[ \t]\)python\([ \t]\|$\),\1${python3}/bin/python3\2,' \
      "$out/share/fish/functions/fish_update_completions.fish"
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrl = map (n: "${n}.asc") urls;
        pgpKeyFingerprint = "0038 3798 6104 8788 35FA  516D 7A67 D962 D88A 709A ";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "Smart and user-friendly command line shell";
    homepage = "http://fishshell.com/";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
