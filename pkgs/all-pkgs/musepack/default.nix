{ stdenv
, autoreconfHook
, fetchTritonPatch
, fetchurl

, libcue
}:

stdenv.mkDerivation rec {
  name = "musepack-${rev}";
  rev = "475";

  src = fetchurl {
    url = "http://files.musepack.net/source/musepack_src_r${rev}.tar.gz";
    sha256 = "0avv88fgiqzjrkwmydkh9dvbli88qal5dma2c42y30vzk4pp9cd4";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    libcue
  ];

  patches = [
    (fetchTritonPatch {
      rev = "3ae03635320741a3ee1b10c1ab25bc7956ef7e7b";
      file = "libmpcdec/01_am-maintainer-mode.patch";
      sha256 = "76b5b7295f5e0be5de7edeb2ef481fe912cef349be5bd26f8b0870572a1ed5ee";
    })
    (fetchTritonPatch {
      rev = "3ae03635320741a3ee1b10c1ab25bc7956ef7e7b";
      file = "libmpcdec/02_link-libm.patch";
      sha256 = "cf7ded3474ecefbe877a672539996b99dd6d62be546b74b70c4d56a7b943952d";
    })
    (fetchTritonPatch {
      rev = "3ae03635320741a3ee1b10c1ab25bc7956ef7e7b";
      file = "libmpcdec/03_mpcchap.patch";
      sha256 = "c6ef8e91b8e4450854d14e47fb4b4bde643b3f22a0d30cd0fae79d1897feb9f7";
    })
    (fetchTritonPatch {
      rev = "3ae03635320741a3ee1b10c1ab25bc7956ef7e7b";
      file = "libmpcdec/04_link-order.patch";
      sha256 = "b184df85c164cb6f37e077b5511bee994e767f25f641d5a44ad3877db0e7eba1";
    })
    (fetchTritonPatch {
      rev = "3ae03635320741a3ee1b10c1ab25bc7956ef7e7b";
      file = "libmpcdec/05_visibility.patch";
      sha256 = "db78faeb4944ab443c89a1da058693e419a8eef1ca4859550afcc6232ec407fb";
    })
    (fetchTritonPatch {
      rev = "3ae03635320741a3ee1b10c1ab25bc7956ef7e7b";
      file = "libmpcdec/1001_missing_extern_kw.patch";
      sha256 = "b736438a93fa5cc10bde753e82a0ce432db5c8c9a4a0689baa738d421166bff4";
    })
    (fetchTritonPatch {
      rev = "3ae03635320741a3ee1b10c1ab25bc7956ef7e7b";
      file = "libmpcdec/add_subdir-objects.patch";
      sha256 = "88e2d7df269c8f19daccb98bd9d1a2bdc9002c7ea03ca093e2dc68b0fb04e636";
    })
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-mpcchap"
  ];

  meta = with stdenv.lib; {
    description = "MusePack commandline utilities and decoder library";
    homepage = http://musepack.net/;
    license = with licenses; [
      bsd3
      lgpl21
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
