{ stdenv
, fetchTritonPatch
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "libnatpmp-20150609";

  src = fetchurl {
    url = "http://miniupnp.free.fr/files/download.php?file=${name}.tar.gz";
    multihash = "QmZYakx3yad4gC1f3yCt4MdUYBjXtUmykU8TQwAuRPbN5b";
    sha256 = "7516a240ed9878219aa9c7ed506d035804dd2dc0faef1ec78997a1a96fc6a406";
  };

  patches = [
    (fetchTritonPatch {
      rev = "712ca0ca230c699311c11db5b17741b3f623ab8b";
      file = "l/libnatpmp/respect-FLAGS-20140401.patch";
      sha256 = "14b21030f87e0bdadcb40df7c5cac952f9c045d70f923844afc7fe67b3f90f59";
    })
    (fetchTritonPatch {
      rev = "712ca0ca230c699311c11db5b17741b3f623ab8b";
      file = "l/libnatpmp/remove-static-lib-20130911.patch";
      sha256 = "65dbd96a79057f8cc07d17ca78234ee8edd4d823ee0f77ccf7ed7f06ff54143f";
    })
  ];

  preBuild = ''
    makeFlagsArray+=("INSTALLPREFIX=$out")
  '';

  meta = with lib; {
    description = "The NAT Port Mapping Protocol (NAT-PMP)";
    homepage = http://miniupnp.free.fr/libnatpmp.html;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
