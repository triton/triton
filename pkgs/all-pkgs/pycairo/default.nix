{ stdenv
, fetchTritonPatch
, fetchurl

, python
, cairo
, xlibsWrapper
, isPyPy
, xorg
}:

with {
  inherit (stdenv.lib)
    optionalString;
};

if (isPyPy) then
  throw "pycairo not supported for interpreter ${python.executable}"
else
stdenv.mkDerivation rec {
  name = "${python.libPrefix}-pycairo-${version}";
  version = "1.10.0";

  src = (
    if python.isPy3 or false then
      fetchurl {
        url = "http://cairographics.org/releases/pycairo-${version}.tar.bz2";
        sha256 = "1gjkf8x6hyx1skq3hhwcbvwifxvrf9qxis5vx8x5igmmgs70g94s";
      }
    else
      fetchurl {
        url = "http://cairographics.org/releases/py2cairo-${version}.tar.bz2";
        sha256 = "0cblk919wh6w0pgb45zf48xwxykfif16qk264yga7h9fdkq3j16k";
      }
  );

  buildInputs = [
    python
    cairo
  ];

  patches = [
    (fetchTritonPatch {
      rev = "6abc19d8cdde923ac47c84223bfa7c784b9b5b94";
      file = "pycairo/pycairo-1.10.0-waf-unpack.patch";
      sha256 = "a53a8e4f00234b373b037be2ec1b78ad070d05eca62d64ab43734a666cc440f3";
    })
  ] ++ (if python.isPy3 or false then [
    (fetchTritonPatch {
      rev = "6abc19d8cdde923ac47c84223bfa7c784b9b5b94";
      file = "pycairo/pycairo-1.10.0-10_test-target-py3.patch";
      sha256 = "1131616e9e553792823a7d8385dba6a9af5b7dce591e4c557489326216c17bcb";
    })
    (fetchTritonPatch {
      rev = "6abc19d8cdde923ac47c84223bfa7c784b9b5b94";
      file = "pycairo/pycairo-1.10.0-svg_check.patch";
      sha256 = "8bf89c4124e8372cd4e2c654e317005c1a6616db7700e74b2455ba2c0c2aab98";
    })
    (fetchTritonPatch {
      rev = "6abc19d8cdde923ac47c84223bfa7c784b9b5b94";
      file = "pycairo/pycairo-1.10.0-101_pycairo-region.patch";
      sha256 = "c0c4dc119b6d61afab23a2ea2da2a16fc1e11171da77707173af5da12229f989";
    })
    (fetchTritonPatch {
      rev = "6abc19d8cdde923ac47c84223bfa7c784b9b5b94";
      file = "pycairo/pycairo-1.10.0-xpyb.patch";
      sha256 = "50e50551665c4e161059b57d5cc21fc00cb2ea3b95c15f193ebf58403745b99a";
    })
  ] else [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "pycairo/py2cairo-1.10.0-svg_check.patch";
      sha256 = "ca3dea3e45b8f519e44023c28d344cedcbfeee6cfc6bc0c1c9efd1f3ab8c323f";
    })
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "pycairo/py2cairo-1.10.0-xpyb.patch";
      sha256 = "256479baa3d3d4333e7fb198871401268ddfc1964a191eeceb1d7125988401f4";
    })
  ]);

  patchWafPython34 = fetchTritonPatch {
    rev = "6abc19d8cdde923ac47c84223bfa7c784b9b5b94";
    file = "pycairo/pycairo-1.10.0-waf-py3_4.patch";
    sha256 = "a4c5526c045972087ec12f68192e14f3f6910b2c2ea4e7a7b742dfd8520cd475";
  };
  patchWafPython35 = fetchTritonPatch {
    rev = "6abc19d8cdde923ac47c84223bfa7c784b9b5b94";
    file = "pycairo/pycairo-1.10.0-waf-py3_5.patch";
    sha256 = "b64888304642a8dd6ef98edefd10f6c1d714dd685c672ce133eba3063675fa3d";
  };
  patchWafEncoding = fetchTritonPatch {
    rev = "6abc19d8cdde923ac47c84223bfa7c784b9b5b94";
    file = "pycairo/pycairo-1.10.0-50_specify-encoding-in-waf.patch";
    sha256 = "c7808278027a1839e1b8bc3110f17d4c20e9ed4abdf9dfae705c050da1748fca";
  };

  configurePhase =
  /* Apply waflib patches after unpacking waf */ ''
    cd $(${python.executable} waf unpack)
    echo 'WAF patch 1'
    patch -p1 < ${patchWafPython34}
    echo 'WAF patch 2'
    patch -p1 < ${patchWafPython35}
  '' + optionalString python.isPy3 or false ''
    echo 'WAF patch 3'
    patch -p1 < ${patchWafEncoding}
  '' + ''
    if [[ "$(dirname "$(pwd)")" != "$sourceRoot" ]] ; then
      cd ..
    fi
    ${python.executable} waf configure --prefix=$out
  '';

  buildPhase = "${python.executable} waf";

  installPhase = "${python.executable} waf install";

  meta = with stdenv.lib; {
    description = "Python bindings for the cairo library";
    homepage = http://cairographics.org/pycairo/;
    license = with licenses; [
      lgpl21
      lgpl3
      mpl11
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
