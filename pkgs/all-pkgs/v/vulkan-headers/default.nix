{ stdenv
, fetchFromGitHub
, lib
, python3
}:

let
  version = "1.1.108";
in
stdenv.mkDerivation rec {
  name = "vulkan-headers-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "KhronosGroup";
    repo = "Vulkan-Docs";
    rev = "v${version}";
    sha256 = "568c023a7888bc5888aaa04bb81c87c8945581ed26c74500025b52ab53aed9e7";
  };

  nativeBuildInputs = [
    python3
  ];

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
