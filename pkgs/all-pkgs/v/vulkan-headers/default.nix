{ stdenv
, fetchFromGitHub
, lib
}:

let
  version = "1.1.75";
in
stdenv.mkDerivation rec {
  name = "vulkan-headers-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "KhronosGroup";
    repo = "Vulkan-Docs";
    rev = "v${version}";
    sha256 = "9178ffb8c28884e2ff4e24fd11cf13aebc1114ac2b28d966306ec86bd5757273";
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
