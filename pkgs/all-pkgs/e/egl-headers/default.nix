{ stdenv
, fetchFromGitHub
, fetchurl
, lib
, mesa-headers
, python3Packages
}:

let
  date = "2019-02-13";
in
stdenv.mkDerivation rec {
  name = "egl-headers-${date}";

  src = fetchurl {
    name = "egl-registry-${date}.tar.xz";
    multihash = "QmcuqWrcyfZnyoEebWeBLyWtkptN29K8UQKdkxxEbZkDEG ";
    sha256 = "829d3a5fb6de4016310cbeeb5b1594b132a4477f41ca4bd74b5b6ea68b9acb8f";
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
      name = "egl-headers-dist-${date}";

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

        # Remove generated headers stored in the repo
        rm -v api/EGL/egl{,ext}.h

        # Fix impure date in headers
        grep -q "time.strftime('%Y%m%d')" api/genheaders.py
        sed -i api/genheaders.py \
          -e "s,time.strftime('%Y%m%d'),'${lib.replaceStrings ["-"] [""] date}',"
      '';

      configurePhase = ":";

      preBuild = ''
        cd api/
      '';

      postBuild = ''
        # Make sure Mesa extensions are included in the header.
        grep -qP '^}$' EGL/eglext.h
        local -a eglext_mesaheaders
        mapfile -t eglext_mesaheaders < <(
          find '${mesa-headers}/include/EGL/' -type f -regex '.*ext.*\.h'
        )
        local eglext_mesaheader
        for eglext_mesaheader in "''${eglext_mesaheaders[@]}"; do
          sed -zE "s,(\n[^\n]*){6}$,\n#include <EGL/$(basename "$eglext_mesaheader")>&," -i EGL/eglext.h
        done
      '';

      installPhase = ''
        for header in {EGL/egl{,ext,platform},KHR/khrplatform}.h; do
          install -D -m644 -v "$header" ${name}/include/"$header"
        done
        for xml in *.xml; do
          install -D -m644 -v "$xml" ${name}/xml/"$(basename "$xml")"
        done

        tar -Jcvf opengl-headers-${date}.tar.xz ${name}/

        install -D -m644 -v 'opengl-headers-${date}.tar.xz' \
          "$out/egl-headers-${date}.tar.xz"
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
