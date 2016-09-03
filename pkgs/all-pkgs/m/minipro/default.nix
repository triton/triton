{ stdenv
, fetchFromGitHub

, libusb
}:

stdenv.mkDerivation {
  name = "minipro-2016-05-12";

  src = fetchFromGitHub {
    version = 1;
    owner = "vdudouyt";
    repo = "minipro";
    rev = "484abde7d924404f5bb30ebc66a80d93b5a65c3e";
    sha256 = "b182717700844efb37b082dba1880f6fceed067735b5058a2d0b69bc9758c1b0";
  };

  buildInputs = [
    libusb
  ];

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$out"
      "UDEV_RULES_DIR=$out/etc/udev/rules.d"
      "COMPLETIONS_DIR=$out/etc/bash_completion.d"
    )
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
