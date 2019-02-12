{ stdenv
, buildPythonPackage
, fetchzip
, lib
}:

let
  rev = "bd11dd1c51ef17592384df927c47023071639f96";
  date = "2018-12-10";
in
buildPythonPackage {
  name = "gyp-${date}";

  src = fetchzip {
    version = 6;
    stripRoot = false;
    purgeTimestamps = true;
    url = "https://chromium.googlesource.com/external/gyp/+archive/${rev}.tar.gz";
    sha256 = "c8ec0d236ed929bb6c3d7e05eb044b0d8206b03a426917730bc175b2aa5a72f1";
  };

  postInstall = ''
    mkdir -p "$dev"
  '';

  postFixup = ''
    mkdir -p "$dev"/{bin,nix-support}
    ln -sv "$out"/bin/gyp "$dev"/bin
    substituteAll '${./setup-hook.sh}' "$dev/nix-support/setup-hook"
  '';

  outputs = [ "out" "dev" ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
