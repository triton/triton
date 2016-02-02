{ stdenv, fetchTritonPatch, fetchFromGitHub, substituteAll, automake, autoconf, libtool, intltool, pkgconfig
, networkmanager, ppp, xl2tpd, strongswan, gtk3, libgnome_keyring
, withGnome ? true }:

stdenv.mkDerivation rec {
  name = "${pname}${if withGnome then "-gnome" else ""}-${version}";
  pname = "NetworkManager-l2tp";
  version = "0.9.8.7";

  src = fetchFromGitHub {
    owner = "seriyps";
    repo = "NetworkManager-l2tp";
    rev = version;
    sha256 = "07gl562p3f6l2wn64f3vvz1ygp3hsfhiwh4sn04c3fahfdys69zx";
  };

  buildInputs = [ networkmanager ppp ]
    ++ stdenv.lib.optionals withGnome [ gtk3 libgnome_keyring ];

  nativeBuildInputs = [ automake autoconf libtool intltool pkgconfig ];

  configureScript = "./autogen.sh";

  configureFlags =
    if withGnome then "--with-gnome" else "--without-gnome";

  postConfigure = "sed 's/-Werror//g' -i Makefile */Makefile";

  patches =
    [ ( substituteAll {
        src =
          (fetchTritonPatch {
            rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
            file = "networkmanager/l2tp-purity.patch";
            sha256 = "e170efd7f3d96c61898a79569b570c435d8503a9ae021ed820feba1c82cb4089";
          });
        inherit xl2tpd strongswan;
      })
    ];

  meta = with stdenv.lib; {
    description = "L2TP plugin for NetworkManager";
    inherit (networkmanager.meta) platforms;
    homepage = https://github.com/seriyps/NetworkManager-l2tp;
    license = licenses.gpl2;
    maintainers = with maintainers; [ abbradar ];
  };
}
