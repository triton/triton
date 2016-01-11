{ stdenv
, fetchurl
, fetchpatch

, python
, cairo
, xlibsWrapper
, isPyPy
, isPy35
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
    if python.is_py3k or false then
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

  patches = [
    ./pycairo-1.10.0-waf-unpack.patch
  ] ++ (if python.is_py3k or false then [
      ./pycairo-1.10.0-10_test-target-py3.patch
      ./pycairo-1.10.0-svg_check.patch
      ./pycairo-1.10.0-101_pycairo-region.patch
      ./pycairo-1.10.0-xpyb.patch
    ] else [
      ./py2cairo-1.10.0-svg_check.patch
      ./py2cairo-1.10.0-xpyb.patch
    ]);

  configurePhase = ''
    # Patch waflib
    cd $(${python.executable} waf unpack)
    echo 'WAF patch 1'
    patch -p1 < ${./pycairo-1.10.0-waf-py3_4.patch}
    echo 'WAF patch 2'
    patch -p1 < ${./pycairo-1.10.0-waf-py3_5.patch}
  '' + optionalString python.is_py3k or false ''
    echo 'WAF patch 3'
    patch -p1 < ${./pycairo-1.10.0-50_specify-encoding-in-waf.patch}
  '' + ''
    cd ..
    ${python.executable} waf configure --prefix=$out
  '';

  buildInputs = [
    python
    cairo
  ];

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
