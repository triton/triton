{ stdenv
, fetchFromGitHub
, lib
}:

let
  version = "1.1.82";
in
stdenv.mkDerivation rec {
  name = "vulkan-headers-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "KhronosGroup";
    repo = "Vulkan-Docs";
    rev = "v${version}";
    sha256 = "ee26d4277fa3001284633e8657d28c07281c0d974d4bb5471f1d839e89fa9d4f";
  };

  configurePhase = "true";

  buildPhase = "true";

  installPhase = ''
    for i in include/vulkan/*; do
      install -D -m 644 -v "$i" \
        "$out"/include/vulkan/"$(basename "$i")"
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
