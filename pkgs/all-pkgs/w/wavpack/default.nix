{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "wavpack-4.80.0";

  src = fetchurl {
    url = "http://www.wavpack.com/${name}.tar.bz2";
    multihash = "QmSj1A89S3tnTSWEF2iSqVdPKiT1aaq3kCekuStgk3BkCU";
    sha256 = "79182ea75f7bd1ca931ed230062b435fde4a4c2e0dbcad048007bd1ef1e66be9";
  };

  postPatch = ''
    sed -i wavpack.pc.in \
      -e '2iexec_prefix=@exec_prefix@'
  '';

  meta = with stdenv.lib; {
    description = "Hybrid audio compression format";
    homepage = http://www.wavpack.com/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
