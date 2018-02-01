{ stdenv
, fetchurl
, lib
, waf

, gtk_2
, gtk_3
, lv2
, libx11
, serd
, sord
, sratom
, qt5
}:

stdenv.mkDerivation rec {
  name = "suil-0.10.0";

  src = fetchurl {
    url = "https://download.drobilla.net/${name}.tar.bz2";
    sha256 = "9895c531f80c7e89a2b4b47de589d73b70bf48db0b0cfe56e5d54237ea4b8848";
  };

  nativeBuildInputs = [
    waf
  ];

  buildInputs = [
    gtk_2
    gtk_3
    lv2
    libx11
    qt5
    serd
    sord
    sratom
  ];

  postPatch = /* Fix compatibility with newer autowaf */ ''
    sed -i wscript \
      -e '/set_cxx11_mode/d'
  '';

  meta = with lib; {
    description = "A library for loading and wrapping LV2 plugin UIs";
    homepage = http://drobilla.net/software/suil;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
