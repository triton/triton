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
      rev = "df8f358d8979bbac156256431d9c116677f33b55";
      file = "i/intltool/0001-perl-compat-5.22.patch";
      sha256 = "635c37f1f7761f2ed220614e4e37907d7f498d322ea5a1ee580b1eb1372e7419";
    })
    (fetchTritonPatch {
      rev = "df8f358d8979bbac156256431d9c116677f33b55";
      file = "i/intltool/0002-perl-compat-5.26.patch";
      sha256 = "713e66dbd1d69abe438775a7130e846b40cb1383254025cb76fd593d2f6e0ce7";
    })
    (fetchTritonPatch {
      rev = "df8f358d8979bbac156256431d9c116677f33b55";
      file = "i/intltool/0003-create-cache-file-atomically.patch";
      sha256 = "13bd6deb65dc94933f132919d4eea4c24354d7c1c1c9e5930cb6e70c75703763";
    })
    (fetchTritonPatch {
      rev = "df8f358d8979bbac156256431d9c116677f33b55";
      file = "i/intltool/0004-absolute-paths.patch";
      sha256 = "100745c58324e737af6b9b6c3691d2a1c43dd46993ab045da23b97d105c157c0";
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
