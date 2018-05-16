{ stdenv
, fetchFromGitHub
}:

let
  date = "2018-05-14";
  rev = "63c76537c652eb5a84360ee043c5f7b63728a622";
self = stdenv.mkDerivation {
  name = "uefi-shell-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "tianocore";
    repo = "edk2";
    inherit rev;
    sha256 = "4e30babc28f6a8bcb2008426c38f645bf69dc0d1115f4885c4ea39b4d7c687ef";
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
