{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "acpid-2.0.31";

  src = fetchurl {
    url = "mirror://sourceforge/acpid2/${name}.tar.xz";
    sha256 = "fc9dc669ed85d9a1739aa76915e0667c6697c5431160f8dfb253046c6a072cc3";
  };

  preBuild = ''
    makeFlagsArray+=(
      "BINDIR=$out/bin"
      "SBINDIR=$out/sbin"
      "MAN8DIR=$out/share/man/man8"
    )
  '';

  meta = with lib; {
    description = "A daemon for delivering ACPI events to userspace programs";
    homepage = http://tedfelix.com/linux/acpid-netlink.html;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
