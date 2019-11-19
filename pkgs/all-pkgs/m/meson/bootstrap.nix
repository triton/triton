{ stdenv
, fetchurl
, python
}:

let
  version = "0.53.2";
in
stdenv.mkDerivation rec {
  name = "meson-${version}";

  src = fetchurl {
    url = "https://github.com/mesonbuild/meson/releases/download/${version}/${name}.tar.gz";
    sha256 = "ec1ba33eea701baca2c1607dac458152dc8323364a51fdef6babda2623413b04";
  };

  buildPhase = ''
    sed -i '/import ctypes/d' mesonbuild/cmake/executor.py
  '';

  installPhase = ''
    mkdir -p "$out"/{bin,share/meson}
    cp -r mesonbuild meson.py "$out"/share/meson
    echo "#!/bin/sh" >>"$out"/bin/meson
    echo "exec '${python}'/bin/python '$out'/share/meson/meson.py \"\$@\"" >>"$out"/bin/meson
    chmod +x "$out"/bin/meson
  '';

  setupHook = ./setup-hook.sh;

  patchShebangsFileIgnore = [
    "${placeholder "out"}/share/meson/.*"
  ];
}
