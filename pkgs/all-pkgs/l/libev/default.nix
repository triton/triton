{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libev-4.27";

  src = fetchurl {
    url = "http://dist.schmorp.de/libev/Attic/${name}.tar.gz";
    multihash = "QmaAQTHb6C4CtipTSPgjriqasjJ5zqxxCoJdeLqKJPRcqA";
    sha256 = "2d5526fc8da4f072dd5c73e18fbb1666f5ef8ed78b73bba12e195cfdd810344e";
  };

  # Fix c89 compliance
  # Without this libverto is broken
  postPatch = ''
    grep -q '__STDC_VERSION__ >= 199901L' ev.h
    sed -i 's,__STDC_VERSION__ >= 199901L.*,__STDC_VERSION__ >= 199901L,' ev.h
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        signifyUrl = map (n: "${n}.sig") src.urls;
        signifyPub = "RWSUBDizLm/GKdlJp8Fr7pMD3pQbONEk+IqVldf+mQn0pYmkiCRDa22s";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "A high-performance event loop/event model with lots of features";
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
