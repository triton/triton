{ stdenv
, fetchFromGitHub
, fetchurl
, lib
, mesa-headers
, python3Packages
}:

let
  date = "2019-05-22";
in
stdenv.mkDerivation rec {
  name = "egl-headers-${date}";

  src = fetchurl {
    name = "egl-registry-${date}.tar.xz";
    multihash = "QmNm7rxGgmdkUR6MxHURgssuf2Z6B3WYNuUviqyyNgG6Nj";
    sha256 = "5c29d717f234b97a55c7bea4bef6c677725b3bc621c23f10e4423691de5aab82";
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
        rev = "4744552d13f4475839d45c2eae7f745bac6ca204";
        sha256 = "80301ee226ec950357a2c0c95229b9313fc5692804160a06f7690be422262231";
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
          "$out"/egl-headers-${date}.tar.xz
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
