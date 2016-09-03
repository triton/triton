{ stdenv
, fetchFromGitHub
}:

let
self = stdenv.mkDerivation {
  name = "uefi-shell-2016-07-11";

  src = fetchFromGitHub {
    version = 1;
    owner = "tianocore";
    repo = "edk2";
    rev = "0f65154396df0cae940b779f715da127c7d0b28f";
    sha256 = "84abc5a491aac61f9b85b1146cbd73efe5297c648966f9556feb0aabd12b35fa";
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
