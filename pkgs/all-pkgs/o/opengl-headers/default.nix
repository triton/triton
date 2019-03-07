{ stdenv
, fetchurl
, fetchFromGitHub
, lib
, python3Packages
}:

# TODO: build release tarballs, repo vendors pdfs

let
  date = "2019-03-01";
in
stdenv.mkDerivation rec {
  name = "opengl-headers-${date}";

  src = fetchurl {
    name = "opengl-headers-${date}.tar.xz";
    multihash = "QmdguDdKPiByjdNGu5bCpsoPcHyrTXq5UoycS3hrpZMtNX";
    sha256 = "64a86c8157ebb9fcdc3adaf563d28e65ad6b0b85b9a609fad0890b5c61ccb423";
  };

  configurePhase = ":";

  buildPhase = ":";

  installPhase = ''
    for api in GL{,ES{,2,3},SC{,2}}; do
      pushd $api/
        while read header; do
          install -D -m644 -v $header $out/include/$(basename "$api")/$header
        done < <(find . -name "*.h" -printf '%P\n')
      popd
    done

    for xml in xml/*.xml; do
      install -D -m644 -v "$xml" \
        "$out"/share/opengl-registry/"$(basename "$xml")"
    done
  '';

  passthru = {
    generateDistTarball = stdenv.mkDerivation rec {
      name = "opengl-headers-${date}";

      src = fetchFromGitHub {
        version = 6;
        owner = "KhronosGroup";
        repo = "OpenGL-Registry";
        rev = "68dba34a93b67d626b1c8b7294e4562bdaf4c996";
        sha256 = "6046f2eef181fe96379d23938de26e32621a59061d384b946db7e969bf16e99a";
      };

      nativeBuildInputs = [
        python3Packages.lxml
        python3Packages.python
      ];

      postPatch = ''
        sed -i xml/genglvnd.py \
          -e 's,drafts/,,'

        # Fix impure date in headers
        grep -q "time.strftime('%Y%m%d')" xml/genheaders.py
        sed -i xml/genheaders.py \
          -e "s,time.strftime('%Y%m%d'),'${lib.replaceStrings ["-"] [""] date}',"
      '';

      configurePhase = ":";

      buildPhase = ''
        # Some headers such as glx.h are not pre-generated, regenerate all
        # to be sure none are missing.
        pushd xml/
          python genheaders.py
        popd
        pushd api/
          for header in glcorearb.h glext.h gl.h; do
            python ../xml/genglvnd.py -registry ../xml/gl.xml GL/$header.h
          done
        popd
        for xml in xml/*.xml; do
          install -D -m644 -v "$xml" \
            api/xml/"$(basename "$xml")"
        done

        tar -Jcvf opengl-headers-${date}.tar.xz api/
      '';

      installPhase = ''
        install -D -m644 -v 'opengl-headers-${date}.tar.xz' \
          "$out/opengl-headers-${date}.tar.xz"
      '';
    };
  };

  meta = with lib; {
    description = "OpenGL, OpenGL ES, and OpenGL ES-SC API headers.";
    homepage = https://github.com/KhronosGroup/OpenGL-Registry;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
