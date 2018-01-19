{ stdenv
, fetchFromGitHub
, lib
}:

stdenv.mkDerivation rec {
  name = "vulkan-headers-1.0.68";

  src = fetchFromGitHub {
    version = 5;
    owner = "KhronosGroup";
    repo = "Vulkan-Docs";
    rev = "57692834480e19201bb9efe9a67f7a65876b7a32";
    sha256 = "3ff5a59407f2ceea10e2be7a052ec2dfdfa593d3186b5d74cf0af85e5468ec35";
  };

  installPhase = ''
    install -D -m 644 -v 'src/vulkan/vulkan.h' \
      "$out/include/vulkan/vulkan.h"
    install -D -m 644 -v 'src/vulkan/vk_platform.h' \
      "$out/include/vulkan/vk_platform.h"
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
