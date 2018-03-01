{ stdenv
, autoreconfHook
, buildPythonPackage
, cython
, fetchFromGitHub
, fetchPyPi
, isPy3
, lib
, nasm
, pip
, setuptools
, unzip
, wheel

, ffmpeg
, imagemagick
, libass
, python
, sphinx
#, tesseract
, zimg

, channel ? "stable"
}:

# This builds the C portion setarately so that we can use setuptools to
# correctly install the python package.

assert isPy3;  # Required for vsscript/vspipe.

let
  inherit (lib)
    optionals;

  sources = {
    "stable" = {
      fetchzipversion = 5;
      version = "43";
      sha256 = "0135e711f900044b990e4cd0b436bbc79c20d11e6a5eff89841cb78553ca4c46";
    };
    "head" = {
      fetchzipversion = 5;
      version = "2017-12-13";
      rev = "8aa4a2d4e47de2df0300074bffce7a4133544911";
      sha256 = "d31479bd671358a90e7eece26b6119cc8c0951a21ac4745cb4d291a0ebba313b";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "vapoursynth-${source.version}";

  src = fetchFromGitHub {
    version = source.fetchzipversion;
    owner = "vapoursynth";
    repo = "vapoursynth";
    rev =
      if channel != "head" then
        "R${source.version}"
      else
        "${source.rev}";
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    autoreconfHook
    cython
    nasm
    pip
    setuptools
    # sphinx
    wheel
  ] ++ optionals (channel != "head") [
    unzip
  ];

  buildInputs = [
    ffmpeg
    imagemagick
    libass
    python
    # tesseract
    zimg
  ];

  configureFlags = [
    "--enable-x86-asm"
    "--enable-core"
    "--enable-vsscript"
    "--enable-vspipe"
    "--enable-python-module"
    "--enable-plugins"
    "--enable-subtext"
    "--enable-eedi3"
    "--enable-imwri"
    "--enable-miscfilters"
    "--enable-morpho"
    /**/"--disable-ocr"
    "--enable-removegrain"
    "--enable-vinverse"
    "--enable-vivtc"
    #"--with-nasm"  # If passed, make flags must be set manually
    #"--with-cython"  # If passed, make flags must be set manually
  ];

  postInstall = /* Re-install the python module with setuptools */ ''
    rm -rfv $out/lib/${python.libPrefix}

    # Fix library search path
    sed -i setup.py \
      -e "s,build,$out/lib,"
    ${python.interpreter} setup.py bdist_wheel --dist-dir=unique_dist_dir/

    pushd unique_dist_dir/
    ${python.interpreter} -m pip -v install *.whl \
      --prefix=$out \
      --build pipUnpackTmp \
      --ignore-installed \
      --no-cache \
      --no-compile \
      --no-deps \
      --no-index
    popd
  '';

  meta = with lib; {
    description = "A video processing framework";
    homepage = https://github.com/vapoursynth/vapoursynth;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
