{ stdenv
, fetchFromGitHub
, fetchurl
, lib
, python3Packages
}:

let
  version = "2019-02-13";
in
stdenv.mkDerivation rec {
  name = "egl-headers-${version}";

  src = fetchurl {
    url = "http://egl-registry.tar.xz";
    multihash = "Qmf3CaunyCXXiyyd6fypvYZv6Q8cDU28ZnJkLqauH26Wxn";
    sha256 = "263cd3090ab76adc3fba3e8e97ba54b44e1109c8e15dfca99851c255319b0f9b";
  };

  configurePhase = ":";

  buildPhase = ":";

  installPhase = ''
    for api in include/{EGL,KHR}; do
      for header in "$api"/*.h; do
        install -D -m644 -v "$header" \
          "$out"/include/"$(basename "$api")"/"$(basename "$header")"
      done
    done
    for xml in xml/*.xml; do
      install -D -m644 -v "$xml" "$out"/share/egl-registry/"$(basename "$xml")"
    done
  '';

  passthru = {
    generateDistTarball = stdenv.mkDerivation rec {
      name = "egl-headers-dist-${version}";

      src = fetchFromGitHub {
        version = 6;
        owner = "KhronosGroup";
        repo = "EGL-Registry";
        rev = "9b12ea69d15aa52f6b4b6dee0302aec14c2e0443";
        sha256 = "f4c57371bf981e3626f7f858b423273b5391cdd160695711c88a70e45f71e9af";
      };

      nativeBuildInputs = [
        python3Packages.lxml
        python3Packages.python
      ];

      postPatch = ''
        patchShebangs api/genheaders.py
        patchShebangs api/reg.py

        rm -v api/EGL/egl{,ext}.h
      '';

      configurePhase = ":";

      preBuild = ''
        cd api/
      '';

      installPhase = ''
        for header in {EGL/egl{,ext,platform},KHR/khrplatform}.h; do
          install -D -m644 -v "$header" ${name}/include/"$header"
        done
        for xml in *.xml; do
          install -D -m644 -v "$xml" ${name}/xml/"$(basename "$xml")"
        done

        tar -Jcvf opengl-headers-${version}.tar.xz ${name}/

        install -D -m644 -v 'opengl-headers-${version}.tar.xz' \
          "$out/egl-headers-${version}.tar.xz"
      '';
    };
  };

  meta = with lib; {
    description = "EGL API and Extension headers.";
    homepage = https://github.com/KhronosGroup/EGL-Registry;
    licenses = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
