{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "sg3_utils-1.43";

  src = fetchurl {
    url = "http://sg.danny.cz/sg/p/${name}.tgz";
    multihash = "QmfAZiUCRW79h4wRoyjxdnMJmd7XZNhAtxoygomd4YcifG";
    sha256 = "190hhkhl096fxkspkr93lrq1n79xz5c5i2n4n4g998qc3yv3hjyq";
  };

  meta = with stdenv.lib; {
    description = "Utilities that send SCSI commands to devices";
    homepage = http://sg.danny.cz/sg/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
