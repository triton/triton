{ stdenv
, autoreconfHook
, fetchFromGitHub
, fetchTritonPatch
, fetchzip

, leptonica
, libpng
, libtiff
, opencl ? null

, debugging ? false
, trainingTools ? false
  , cairo
  , icu
  , pango

# Optional languages (uses ISO 639-2 codes)
, lang-afr ? false
, lang-amh ? false
, lang-ara ? false
, lang-asm ? false
, lang-aze ? false
, lang-aze_cyrl ? false
, lang-bel ? false
, lang-ben ? false
#, lang-bih ? false
, lang-bod ? false
, lang-bos ? false
, lang-bul ? false
, lang-cat ? false
, lang-ceb ? false
, lang-ces ? false
, lang-chi_sim ? false
, lang-chi_tra ? false
, lang-chr ? false
, lang-cym ? false
, lang-dan ? false
, lang-deu ? false
, lang-dzo ? false
, lang-ell ? false
, lang-eng ? true
, lang-enm ? false
, lang-epo ? false
, lang-est ? false
, lang-eus ? false
, lang-fas ? false
, lang-fin ? false
, lang-fra ? true
, lang-frk ? false
, lang-frm ? false
, lang-gle ? false
#, lang-gle_uncial ? false
, lang-glg ? false
, lang-guj ? false
, lang-hat ? false
, lang-heb ? false
, lang-hin ? false
, lang-hrv ? false
, lang-hun ? false
, lang-iku ? false
, lang-ind ? false
, lang-isl ? false
, lang-ita ? false
, lang-ita_old ? false
, lang-jav ? false
, lang-jpn ? false
, lang-kan ? false
, lang-kat ? false
, lang-kat_old ? false
, lang-kaz ? false
, lang-khm ? false
, lang-kir ? false
, lang-kor ? false
, lang-kur ? false
, lang-lao ? false
, lang-lat ? false
, lang-lav ? false
, lang-lit ? false
, lang-mal ? false
, lang-mar ? false
, lang-mkd ? false
, lang-mlt ? false
, lang-msa ? false
, lang-mya ? false
, lang-nep ? false
, lang-nld ? false
, lang-nor ? false
, lang-ori ? false
, lang-pan ? false
#, lang-per ? false
, lang-pol ? false
, lang-por ? false
, lang-pus ? false
, lang-ron ? false
, lang-rus ? false
, lang-san ? false
, lang-sin ? false
, lang-slk ? false
, lang-slv ? false
, lang-spa ? false
, lang-spa_old ? false
, lang-sqi ? false
, lang-srp ? false
, lang-srp_latn ? false
, lang-swa ? false
, lang-swe ? false
, lang-syr ? false
, lang-tam ? false
, lang-tel ? false
, lang-tgk ? false
, lang-tgl ? false
, lang-tha ? false
, lang-tir ? false
, lang-tur ? false
, lang-uig ? false
, lang-ukr ? false
, lang-urd ? false
, lang-uzb ? false
, lang-uzb_cyrl ? false
, lang-vie ? false
, lang-yid ? false
#, lang-zlm ? false
}:

let
  inherit (stdenv.lib)
    enFlag
    optionalString;
in

let
  tessdata = stdenv.mkDerivation {
    name = "tessdata-2016-08-03";

    src = fetchFromGitHub {
      owner = "tesseract-ocr";
      repo = "tessdata";
      rev = "3cf1e2df1fe1d1da29295c9ef0983796c7958b7d";
      sha256 = "6d646243ae7a2fc976182c5aa03dd9e395ef1507cc2e461fad6b0d6497818b06";
    };

    phases = [ "unpackPhase" "installPhase" ];

    installPhase = ''
        mkdir -p $out/
      '' +
      optionalString lang-afr ''
        cp -v afr.* $out
      '' +
      optionalString lang-amh ''
        cp -v amh.* $out
      '' +
      optionalString lang-ara ''
        cp -v ara.* $out
      '' +
      optionalString lang-asm ''
        cp -v asm.* $out
      '' +
      optionalString lang-aze ''
        cp -v aze.* $out
      '' +
      optionalString lang-aze_cyrl ''
        cp -v aze_cyrl.* $out
      '' +
      optionalString lang-bel ''
        cp -v bel.* $out
      '' +
      optionalString lang-ben ''
        cp -v ben.* $out
      '' +
      optionalString lang-bod ''
        cp -v bod.* $out
      '' +
      optionalString lang-bos ''
        cp -v bos.* $out
      '' +
      optionalString lang-bul ''
        cp -v bul.* $out
      '' +
      optionalString lang-cat ''
        cp -v cat.* $out
      '' +
      optionalString lang-ceb ''
        cp -v ceb.* $out
      '' +
      optionalString lang-ces ''
        cp -v ces.* $out
      '' +
      optionalString lang-chi_sim ''
        cp -v chi_sim.* $out
      '' +
      optionalString lang-chi_tra ''
        cp -v chi_tra.* $out
      '' +
      optionalString lang-chr ''
        cp -v chr.* $out
      '' +
      optionalString lang-cym ''
        cp -v cym.* $out
      '' +
      optionalString lang-dan ''
        cp -v dan.* $out
      '' +
      optionalString lang-deu ''
        cp -v deu.* $out
      '' +
      optionalString lang-dzo ''
        cp -v dzo.* $out
      '' +
      optionalString lang-ell ''
        cp -v ell.* $out
      '' +
      optionalString lang-eng ''
        cp -v eng.* $out
      '' +
      optionalString lang-enm ''
        cp -v enm.* $out
      '' +
      optionalString lang-epo ''
        cp -v epo.* $out
      '' +
      optionalString lang-est ''
        cp -v est.* $out
      '' +
      optionalString lang-eus ''
        cp -v eus.* $out
      '' +
      optionalString lang-fas ''
        cp -v fas.* $out
      '' +
      optionalString lang-fin ''
        cp -v fin.* $out
      '' +
      optionalString lang-fra ''
        cp -v fra.* $out
      '' +
      optionalString lang-frk ''
        cp -v frk.* $out
      '' +
      optionalString lang-frm ''
        cp -v frm.* $out
      '' +
      optionalString lang-gle ''
        cp -v gle.* $out
      '' +
      optionalString lang-glg ''
        cp -v glg.* $out
      '' +
      optionalString lang-guj ''
        cp -v guj.* $out
      '' +
      optionalString lang-hat ''
        cp -v hat.* $out
      '' +
      optionalString lang-heb ''
        cp -v heb.* $out
      '' +
      optionalString lang-hin ''
        cp -v hin.* $out
      '' +
      optionalString lang-hrv ''
        cp -v hrv.* $out
      '' +
      optionalString lang-hun ''
        cp -v hun.* $out
      '' +
      optionalString lang-iku ''
        cp -v iku.* $out
      '' +
      optionalString lang-ind ''
        cp -v ind.* $out
      '' +
      optionalString lang-isl ''
        cp -v isl.* $out
      '' +
      optionalString lang-ita ''
        cp -v ita.* $out
      '' +
      optionalString lang-ita_old ''
        cp -v ita_old.* $out
      '' +
      optionalString lang-jav ''
        cp -v jav.* $out
      '' +
      optionalString lang-jpn ''
        cp -v jpn.* $out
      '' +
      optionalString lang-kan ''
        cp -v kan.* $out
      '' +
      optionalString lang-kat ''
        cp -v kat.* $out
      '' +
      optionalString lang-kat_old ''
        cp -v kat_old.* $out
      '' +
      optionalString lang-kaz ''
        cp -v kaz.* $out
      '' +
      optionalString lang-khm ''
        cp -v khm.* $out
      '' +
      optionalString lang-kir ''
        cp -v kir.* $out
      '' +
      optionalString lang-kor ''
        cp -v kor.* $out
      '' +
      optionalString lang-kur ''
        cp -v kur.* $out
      '' +
      optionalString lang-lao ''
        cp -v lao.* $out
      '' +
      optionalString lang-lat ''
        cp -v lat.* $out
      '' +
      optionalString lang-lav ''
        cp -v lav.* $out
      '' +
      optionalString lang-lit ''
        cp -v lit.* $out
      '' +
      optionalString lang-mal ''
        cp -v mal.* $out
      '' +
      optionalString lang-mar ''
        cp -v mar.* $out
      '' +
      optionalString lang-mkd ''
        cp -v mkd.* $out
      '' +
      optionalString lang-mlt ''
        cp -v mlt.* $out
      '' +
      optionalString lang-msa ''
        cp -v msa.* $out
      '' +
      optionalString lang-mya ''
        cp -v mya.* $out
      '' +
      optionalString lang-nep ''
        cp -v nep.* $out
      '' +
      optionalString lang-nld ''
        cp -v nld.* $out
      '' +
      optionalString lang-nor ''
        cp -v nor.* $out
      '' +
      optionalString lang-ori ''
        cp -v ori.* $out
      '' +
      optionalString lang-pan ''
        cp -v pan.* $out
      '' +
      optionalString lang-pol ''
        cp -v pol.* $out
      '' +
      optionalString lang-por ''
        cp -v por.* $out
      '' +
      optionalString lang-pus ''
        cp -v pus.* $out
      '' +
      optionalString lang-ron ''
        cp -v ron.* $out
      '' +
      optionalString lang-rus ''
        cp -v rus.* $out
      '' +
      optionalString lang-san ''
        cp -v san.* $out
      '' +
      optionalString lang-sin ''
        cp -v sin.* $out
      '' +
      optionalString lang-slk ''
        cp -v slk.* $out
      '' +
      optionalString lang-slv ''
        cp -v slv.* $out
      '' +
      optionalString lang-spa ''
        cp -v spa.* $out
      '' +
      optionalString lang-spa_old ''
        cp -v spa_old.* $out
      '' +
      optionalString lang-sqi ''
        cp -v sqi.* $out
      '' +
      optionalString lang-srp ''
        cp -v srp.* $out
      '' +
      optionalString lang-srp_latn ''
        cp -v srp_latn.* $out
      '' +
      optionalString lang-swa ''
        cp -v swa.* $out
      '' +
      optionalString lang-swe ''
        cp -v swe.* $out
      '' +
      optionalString lang-syr ''
        cp -v syr.* $out
      '' +
      optionalString lang-tam ''
        cp -v tam.* $out
      '' +
      optionalString lang-tel ''
        cp -v tel.* $out
      '' +
      optionalString lang-tgk ''
        cp -v tgk.* $out
      '' +
      optionalString lang-tgl ''
        cp -v tgl.* $out
      '' +
      optionalString lang-tha ''
        cp -v tha.* $out
      '' +
      optionalString lang-tir ''
        cp -v tir.* $out
      '' +
      optionalString lang-tur ''
        cp -v tur.* $out
      '' +
      optionalString lang-uig ''
        cp -v uig.* $out
      '' +
      optionalString lang-ukr ''
        cp -v ukr.* $out
      '' +
      optionalString lang-urd ''
        cp -v urd.* $out
      '' +
      optionalString lang-uzb ''
        cp -v uzb.* $out
      '' +
      optionalString lang-uzb_cyrl ''
        cp -v uzb_cyrl.* $out
      '' +
      optionalString lang-vie ''
        cp -v vie.* $out
      '' +
      optionalString lang-yid ''
        cp -v yid.* $out
      '';
  };
in

stdenv.mkDerivation rec {
  name = "tesseract-${version}";
  version = "3.04.00";

  src = fetchzip {
    url = "https://github.com/tesseract-ocr/tesseract/archive/${version}.tar.gz";
    sha256 = "c333c95030740d52cc8ae69b2c7db773ab0fb430d844a6bbea6a52fb130a2381";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    leptonica
    libpng
    libtiff
  ];

  patches = [
    (fetchTritonPatch {
      rev = "838bc0c6a5bcb9fda08eaf4912162b0bdf8cea51";
      file = "tesseract/tesseract-3.04.00-leptonica-1.73-compat.patch";
      sha256 = "45cc314f093d462f14e623c3e8a2bfea6db612cb11d231bfec1bf36a350dece6";
    })
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-graphics"
    "--disable-embedded"
    (enFlag "opencl" (opencl != null) null)
    "--disable-visibility"
    "--enable-multiple-libraries"
    # Flag is not a boolean
    #"--enable-tessdata-prefix"
    (enFlag "debug" debugging null)
    "--enable-largefile"
  ];

  /* Fix leptonica header search path */
  LIBLEPT_HEADERSDIR = "${leptonica}/include";

  postInstall = /* Symlink all installed tessdata files into tesseract */ ''
    for i in ${tessdata}/* ; do
      ln -fsv $i $out/share/tessdata
    done
  '';

  meta = with stdenv.lib; {
    description = "OCR engine";
    homepage = https://github.com/tesseract-ocr;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
