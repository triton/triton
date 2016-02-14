rec {

  # Content-addressable Nix mirrors
  hashedMirrors = [
    http://tarballs.nixos.org
  ];

  # Mirrors for mirror://site/filename URIs, where "site" is
  # "sourceforge", "gnu", etc.

  apache = [
    https://www.apache.org/dist/
    http://apache.mirrors.pair.com/
    http://archive.apache.org/dist/ # fallback for old releases
  ];

  # Bioconductor mirrors
  bioc = [
    http://bioconductor.jp/packages/3.2/bioc/
    http://bioconductor.statistik.tu-dortmund.de/packages/3.2/bioc/
    http://mirrors.ebi.ac.uk/bioconductor/packages/3.2/bioc/
    http://mirrors.ustc.edu.cn/bioc/3.2/bioc/
  ];

  # BitlBee mirrors, see http://www.bitlbee.org/main.php/mirrors.html
  bitlbee = [
    http://get.us.bitlbee.org/
    http://get.bitlbee.org/
  ];

  chromium = [
    https://commondatastorage.googleapis.com/chromium-browser-official/
    https://gsdview.appspot.com/chromium-browser-official/
  ];

  cpan = [
    https://mirrors.kernel.org/CPAN/
    http://cpan.pair.com/pub/CPAN
    http://cpan.perl.org/
    http://backpan.perl.org/  # for old releases
  ];

  cran = [
    http://watson.nci.nih.gov/cran_mirror/
    http://cran.revolutionanalytics.com/
    http://cran.mtu.edu/
  ];

  debian = [
    https://mirrors.kernel.org/debian/
    http://debian.mirrors.pair.com/debian/
    http://ftp.debian.org/debian/
    ftp://ftp.debian.org/debian/
    http://archive.debian.org/debian-archive/debian/
  ];

  fedora = [
    https://mirrors.kernel.org/fedora/
    http://fedora.mirrors.pair.com/
    http://archives.fedoraproject.org/pub/fedora/
    http://fedora.osuosl.org/
    http://fedora.bhs.mirrors.ovh.net/
    http://mirror.csclub.uwaterloo.ca/fedora/
    http://ftp.linux.cz/pub/linux/fedora/
    http://mirror.1000mbps.com/fedora/
    http://archives.fedoraproject.org/pub/archive/fedora/
  ];

  gcc = [
    ftp://gcc.gnu.org/pub/gcc/
    ftp://ftp.nluug.nl/mirror/languages/gcc/
    ftp://ftp.fu-berlin.de/unix/languages/gcc/
  ];

  gentoo = [
    https://mirrors.kernel.org/gentoo/
    http://gentoo.mirrors.pair.com/
    http://distfiles.gentoo.org/
  ];

  gnome = [
    # This one redirects to some mirror closeby, so it should be all you need.
    https://download.gnome.org/
  ];

  gnu = [
    https://mirrors.kernel.org/gnu/
    http://gnu.mirrors.pair.com/

    # This one redirects to a (supposedly) nearby and (supposedly) up-to-date
    # mirror.
    http://ftpmirror.gnu.org/

    # This one is the master repository, and thus it's always up-to-date.
    http://ftp.gnu.org/pub/gnu/
  ];

  gnupg = [
    https://gnupg.org/ftp/gcrypt/
    ftp://ftp.gnupg.org/gcrypt/
  ];

  # Hackage mirrors
  hackage = [
    http://hackage.haskell.org/package/
    http://hdiff.luite.com/packages/archive/package/
  ];

  # ImageMagick mirrors, see http://www.imagemagick.org/script/download.php
  imagemagick = [
    http://www.imagemagick.org/download/
    ftp://ftp.sunet.se/pub/multimedia/graphics/ImageMagick/ # also contains older versions removed from most mirrors
    http://ftp.sunet.se/pub/multimedia/graphics/ImageMagick/
    ftp://ftp.imagemagick.org/pub/ImageMagick/
    http://ftp.fifi.org/ImageMagick/
    ftp://ftp.fifi.org/ImageMagick/
    http://imagemagick.mirrorcatalogs.com/
    ftp://imagemagick.mirrorcatalogs.com/imagemagick
  ];

  # Mirrors of ftp://ftp.kde.org/pub/kde/.
  kde = [
    http://kde.mirrors.pair.com/
    "http://download.kde.org/download.php?url="
    ftp://ftp.kde.org/pub/kde/
  ];

  # kernel.org's /pub (/pub/{linux,software}) tree.
  kernel = [
    http://www.all.kernel.org/pub/
    http://kernel.mirrors.pair.com/
    http://mirrors.xmission.com/kernel.org/
  ];

  metalab = [
    ftp://ftp.gwdg.de/pub/linux/metalab/
  ];

  mysql = [
    https://cdn.mysql.com/Downloads/
    http://mysql.mirrors.pair.com/Downloads/
  ];

  openbsd = [
    http://openbsd.mirrors.pair.com/
    http://ftp.openbsd.org/pub/OpenBSD/
  ];

  opensuse = [
    http://opensuse.temple.edu/distribution/
    http://ftp.opensuse.org/pub/opensuse/distribution/
  ];
  # Old SUSE distributions.  Unfortunately there is no master site,
  # since SUSE actually delete their old distributions (see
  # ftp://ftp.suse.com/pub/suse/discontinued/deleted-20070817/README.txt).
  oldsuse = [
    ftp://ftp.gmd.de/ftp.suse.com-discontinued/
  ];

  postgresql = [
    http://ftp.postgresql.org/pub/
    ftp://ftp.postgresql.org/pub/
    ftp://ftp-archives.postgresql.org/pub/
  ];

  # Roy marples mirrors
  roy = [
    http://roy.marples.name/downloads/
    http://roy.aydogan.net/
    http://cflags.cc/roy/
  ];

  sagemath = [
    http://boxen.math.washington.edu/home/sagemath/sage-mirror/src/
    http://mirrors.hustunique.com/sagemath/src/
    http://mirrors.xmission.com/sage/src/
    http://sage.asis.io/src/
    http://www.mirrorservice.org/sites/www.sagemath.org/src/

    # Old versions
    http://www.cecm.sfu.ca/sage/src/
    http://sagemath.org/src-old/
  ];

  samba = [
    https://samba.org/ftp/
  ];

  savannah = [
    http://gnu.mirrors.pair.com/savannah/savannah/
    http://download.savannah.gnu.org/releases/
  ];

  sourceforge = [
    http://prdownloads.sourceforge.net/
    http://heanet.dl.sourceforge.net/sourceforge/
    http://surfnet.dl.sourceforge.net/sourceforge/
    http://dfn.dl.sourceforge.net/sourceforge/
    http://osdn.dl.sourceforge.net/sourceforge/
    http://kent.dl.sourceforge.net/sourceforge/
  ];

  # SourceForge.jp
  sourceforgejp = [
    http://osdn.dl.sourceforge.jp/
    http://jaist.dl.sourceforge.jp/
  ];

  ubuntu = [
    https://mirrors.kernel.org/ubuntu/
    http://ubuntu.mirrors.pair.com/
    http://archive.ubuntu.com/ubuntu/
    http://old-releases.ubuntu.com/ubuntu/
  ];

  xfce = [
    http://archive.xfce.org/
  ];

  xorg = [
    http://xorg.mirrors.pair.com/
    http://mirror.us.leaseweb.net/xorg/
    http://xorg.freedesktop.org/releases/
    http://ftp.x.org/pub/
  ];
}
