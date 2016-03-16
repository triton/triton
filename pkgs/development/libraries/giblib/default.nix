{ stdenv
, fetchurl

, xlibsWrapper
, imlib2
}:

stdenv.mkDerivation rec {
  name = "giblib-1.2.4";
  
  src = fetchurl {
    url = "http://linuxbrit.co.uk/downloads/${name}.tar.gz";
    multihash = "QmRj52kM1C8pk8eDoM2mMSU8Cqeb2cznzvUR7B2wfBqZLi";
    sha256 = "1b4bmbmj52glq0s898lppkpzxlprq9aav49r06j2wx4dv3212rhp";
  };
  
  buildInputs = [
    xlibsWrapper
    imlib2
  ];

  meta = with stdenv.lib; {
    homepage = http://linuxbrit.co.uk/giblib/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
