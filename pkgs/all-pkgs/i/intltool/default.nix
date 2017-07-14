{ stdenv
, fetchTritonPatch
, fetchurl

, gettext
, perlPackages
}:

let
  version = "0.51.0";
in
stdenv.mkDerivation rec {
  name = "intltool-${version}";

  src = fetchurl {
    url = "https://launchpad.net/intltool/trunk/${version}/+download/${name}.tar.gz";
    multihash = "QmYHDppGQTJfhnQzENFcLPD7iRmqWM9rbqZVtVeHjpZZVu";
    sha256 = "1karx4sb7bnm2j67q0q74hspkfn6lqprpy5r99vkn5bb36a4viv7";
  };

  patches = [
    (fetchTritonPatch {
      rev = "e04c105d75d64c7dc9b99b21e843318fc1de43b7";
      file = "i/intltool/0001-perl-compat-5.26.patch";
      sha256 = "3a02adba6d81b55834934ff2b8cefd45c5461e2693d711b1ba7a633fc3b748a7";
    })
    (fetchTritonPatch {
      rev = "e04c105d75d64c7dc9b99b21e843318fc1de43b7";
      file = "i/intltool/0002-create-cache-file-atomically.patch";
      sha256 = "13bd6deb65dc94933f132919d4eea4c24354d7c1c1c9e5930cb6e70c75703763";
    })
  ];

  # Most packages just expect these to be propagated
  propagatedBuildInputs = [
    gettext
    perlPackages.perl
    perlPackages.XMLParser
  ];

  meta = with stdenv.lib; {
    description = "Translation helper tool";
    homepage = http://launchpad.net/intltool/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      raskin
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
