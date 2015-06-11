{ stdenv, fetchurl, fetchpatch, bison, flex, autoconf, automake, openssl }:

stdenv.mkDerivation rec {
  name = "bip-${version}";
  version = "0.8.9";

  # fetch sources from debian, because the creator's website provides
  # the files only via https but with an untrusted certificate.
  src = fetchurl {
    url = "mirror://debian/pool/main/b/bip/bip_${version}.orig.tar.gz";
    sha256 = "0q942g9lyd8pjvqimv547n6vik5759r9npw3ws3bdj4ixxqhz59w";
  };

  # includes an important security patch
  patches = [
    (fetchpatch {
      url = "https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/net-irc/bip/files/bip-freenode.patch";
      sha256 = "05qy7a62p16f5knrsdv2lkhc07al18qq32ciq3k4r0lq1wbahj2y";
    })
  ];

  configureFlags = [ "--disable-pie" ];

  buildInputs = [ bison flex autoconf automake openssl ];

  meta = {
    description = "An IRC proxy (bouncer)";
    homepage = http://bip.milkypond.org/;
    license = stdenv.lib.licenses.gpl2;
    downloadPage= "https://projects.duckcorp.org/projects/bip/files";
    inherit version;
  };
}
