{ stdenv
, autoconf
, automake
, fetchurl
, fetchpatch
, gettext
, gnulib
, gnum4
, libtool
, perl

, freetype
, giflib
, glib
, libjpeg
, libpng
, libtiff
, libxml2
, readline
, uthash
, zlib
}:

let
  version = "20161005";
in
stdenv.mkDerivation rec {
  name = "fontforge-${version}";

  src = fetchurl {
    url = "https://github.com/fontforge/fontforge/archive/${version}.tar.gz";
    sha256 = "faf5e911a634b6931060858b093b22f1c5bf549969e7dbf4c4ee6f7372fc1c75";
  };

  patches = [
    (fetchpatch {
      name = "use-system-uthash.patch";
      url = "http://pkgs.fedoraproject.org/cgit/fontforge.git/plain/"
        + "fontforge-20140813-use-system-uthash.patch?id=8bdf933";
      multihash = "QmcmrPTJafenDXyxb27fUwp4z9gQuwUFUyDQyH7xRmYiLP";
      sha256 = "0n8i62qv2ygfii535rzp09vvjx4qf9zp5qq7qirrbzm1l9gykcjy";
    })
  ];

  patchFlags = "-p0";

  nativeBuildInputs = [
    autoconf
    automake
    gettext
    gnum4
    libtool
    perl
  ];

  buildInputs = [
    freetype
    giflib
    glib
    libjpeg
    libpng
    libtiff
    libxml2
    readline
    uthash
    zlib
  ];

  preConfigure = ''
    sed -i '/func_check_versions ()/{N;s/{/{ return 0/}' bootstrap

    unpackFile "${gnulib.src}"
    mv gnulib* gnulib

    ./bootstrap --skip-git --gnulib-srcdir=./gnulib
  '';

  configureFlags = [
    "--disable-python-extension"
    "--disable-python-scripting"
  ];

  meta = with stdenv.lib; {
    description = "A font editor";
    homepage = http://fontforge.github.io;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

