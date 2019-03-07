{ stdenv
, fetchFromGitHub
, fetchurl
, lib
, python3Packages
}:

let
  date = "2019-02-13";
in
stdenv.mkDerivation rec {
  name = "egl-headers-${date}";

  src = fetchurl {
    url = "http://egl-registry.tar.xz";
    multihash = "Qma9rtynxUNEy8AxSsuEE7kCNqYvMU8bTeJQL8CiYo27TU";
    sha256 = "de926279c49b99d2d702217a073cf25b60d58cb81a30a91150cc0892b2b32532";
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
