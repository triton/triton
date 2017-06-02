{ stdenv
, fetchFromGitHub
}:

let
  date = "2017-06-02";
  rev = "b0b626ea2f16faca9f864599384fd184a89e0195";
self = stdenv.mkDerivation {
  name = "uefi-shell-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "tianocore";
    repo = "edk2";
    inherit rev;
    sha256 = "f3d950c119de75467650ea98d36cce1164b04522ed82c791159db22c376044a7";
  };

  installPhase = ''
    mkdir -p "$out/share/efi"
    cp ShellBinPkg/UefiShell/X64/Shell.efi "$out/share/efi/Shell.efi"
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
};
in self // {
  shell = "${self}/share/efi/Shell.efi";
}
