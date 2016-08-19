{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "sg3_utils-1.43";

  src = fetchurl {
    url = "http://sg.danny.cz/sg/p/${name}.tgz";
    multihash = "QmfAZiUCRW79h4wRoyjxdnMJmd7XZNhAtxoygomd4YcifG";
    sha256 = "1dcb7a0309bd0ba3d4a83acb526973b80106ee26cd9f7398186cd3f0633c9ef3";
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
