{ stdenv
, fetchFromGitHub
, lib
, python3
}:

let
  version = "1.1.103";
in
stdenv.mkDerivation rec {
  name = "vulkan-headers-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "KhronosGroup";
    repo = "Vulkan-Docs";
    rev = "v${version}";
    sha256 = "e1207bd30078c431e31cc0622b99995936ebb9439a307c36b2ff276203316b8a";
  };

  nativeBuildInputs = [
    python3
  ];

  postPatch = ''
    #patchShebangs xml/genheaders.py
    rm -v include/vulkan/*.h
  '';

  configurePhase = ":";

  preBuild = ''
    cd xml/
  '';

  installPhase = ''
    cd ../

    local vulkan_header
    for vulkan_header in include/vulkan/*.h; do
      install -D -m 644 -v "$vulkan_header" \
        "$out"/include/vulkan/"$(basename "$vulkan_header")"
    done

    local vulkan_xml
    for vulkan_xml in xml/*.xml; do
      install -D -m644 -v "$vulkan_xml" \
        "$out"/share/vulkan-registry/"$(basename "$vulkan_xml")"
    done
  '';

  meta = with lib; {
    description = "The Vulkan API Specification";
    homepage = https://github.com/KhronosGroup/Vulkan-Docs;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
