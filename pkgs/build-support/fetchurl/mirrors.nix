rec {

  # Content-addressable Nix mirrors
  hashedMirrors = [
    http://tarballs.nixos.org
  ];

  # Mirrors for mirror://site/filename URIs, where "site" is
  # "sourceforge", "gnu", etc.

  # SourceForge
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

  # GNU (http://www.gnu.org/prep/ftp.html).
  gnu = [
    http://mirrors.kernel.org/gnu/
    http://gnu.mirrors.pair.com/

    # This one redirects to a (supposedly) nearby and (supposedly) up-to-date
    # mirror.
    http://ftpmirror.gnu.org/

    # This one is the master repository, and thus it's always up-to-date.
    http://ftp.gnu.org/pub/gnu/
  ];

  # GCC
  gcc = [
    ftp://gcc.gnu.org/pub/gcc/
    ftp://ftp.nluug.nl/mirror/languages/gcc/
    ftp://ftp.fu-berlin.de/unix/languages/gcc/
  ];

  # GnuPG
  gnupg = [
    ftp://ftp.gnupg.org/gcrypt/
  ];

  # kernel.org's /pub (/pub/{linux,software}) tree.
  kernel = [
    http://www.all.kernel.org/pub/
    http://kernel.mirrors.pair.com/
  ];

  # Mirrors of ftp://ftp.kde.org/pub/kde/.
  kde = [
    http://kde.mirrors.pair.com/
    "http://download.kde.org/download.php?url="
    ftp://ftp.kde.org/pub/kde/
  ];

  # Gentoo
  gentoo = [
    http://mirrors.kernel.org/gentoo/
    http://gentoo.mirrors.pair.com/
    http://distfiles.gentoo.org/
  ];

  savannah = [
    http://gnu.mirrors.pair.com/savannah/savannah/
    http://download.savannah.gnu.org/releases/
  ];

  samba = [
    http://samba.org/ftp/
  ];

  # BitlBee mirrors, see http://www.bitlbee.org/main.php/mirrors.html
  bitlbee = [
    http://get.us.bitlbee.org/
    http://get.bitlbee.org/
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

  # CPAN
  cpan = [
    http://mirrors.kernel.org/CPAN/
    http://cpan.pair.com/pub/CPAN
    http://cpan.perl.org/
    http://backpan.perl.org/  # for old releases
  ];

  # Debian
  debian = [
    http://debian.mirrors.pair.com/debian/
    http://ftp.debian.org/debian/
    ftp://ftp.debian.org/debian/
    http://archive.debian.org/debian-archive/debian/
  ];

  # Ubuntu
  ubuntu = [
    http://ubuntu.mirrors.pair.com/
    http://archive.ubuntu.com/ubuntu/
    http://old-releases.ubuntu.com/ubuntu/
  ];

  # Fedora
  fedora = [
    http://fedora.mirrors.pair.com/
    http://archives.fedoraproject.org/pub/fedora/
    http://fedora.osuosl.org/
    http://fedora.bhs.mirrors.ovh.net/
    http://mirror.csclub.uwaterloo.ca/fedora/
    http://ftp.linux.cz/pub/linux/fedora/
    http://mirror.1000mbps.com/fedora/
    http://archives.fedoraproject.org/pub/archive/fedora/
  ];

  # Old SUSE distributions.  Unfortunately there is no master site,
  # since SUSE actually delete their old distributions (see
  # ftp://ftp.suse.com/pub/suse/discontinued/deleted-20070817/README.txt).
  oldsuse = [
    ftp://ftp.gmd.de/ftp.suse.com-discontinued/
  ];

  # openSUSE
  opensuse = [
    http://opensuse.temple.edu/distribution/
    http://ftp.opensuse.org/pub/opensuse/distribution/
  ];

  # Gnome
  gnome = [
    http://gnome.mirrors.pair.com/
    # This one redirects to some mirror closeby, so it should be all you need.
    http://download.gnome.org/
  ];

  xfce = [
    http://archive.xfce.org/
  ];

  # X.Org
  xorg = [
    http://xorg.mirrors.pair.com/
    http://xorg.freedesktop.org/releases/
    http://ftp.x.org/pub/ # often incomplete (e.g. files missing from X.org 7.4)
  ];

  # Apache
  apache = [
    http://apache.mirrors.pair.com/
    http://www.apache.org/dist/
    http://archive.apache.org/dist/ # fallback for old releases
  ];

  postgresql = [
    http://ftp.postgresql.org/pub/
    ftp://ftp.postgresql.org/pub/
    ftp://ftp-archives.postgresql.org/pub/
  ];

  metalab = [
    ftp://mirrors.kernel.org/metalab/
    ftp://ftp.gwdg.de/pub/linux/metalab/
    ftp://ftp.xemacs.org/sites/metalab.unc.edu/
  ];

  # Bioconductor mirrors (from http://bioconductor.org/about/mirrors)
  # The commented-out ones don't seem to allow direct package downloads;
  # they serve error messages that result in hash mismatches instead.
  bioc = [
    # http://bioc.ism.ac.jp/3.2/bioc/
    # http://bioc.openanalytics.eu/3.2/bioc/
    # http://bioconductor.fmrp.usp.br/3.2/bioc/
    # http://mirror.aarnet.edu.au/pub/bioconductor/3.2/bioc/
    # http://watson.nci.nih.gov/bioc_mirror/3.2/bioc/
    http://bioconductor.jp/packages/3.2/bioc/
    http://bioconductor.statistik.tu-dortmund.de/packages/3.2/bioc/
    http://mirrors.ebi.ac.uk/bioconductor/packages/3.2/bioc/
    http://mirrors.ustc.edu.cn/bioc/3.2/bioc/
  ];

  # CRAN mirrors (from http://cran.r-project.org/mirrors.html)
  cran = [
    http://watson.nci.nih.gov/cran_mirror/
    http://cran.revolutionanalytics.com/
    http://cran.mtu.edu/
  ];

  # Hackage mirrors
  hackage = [
    http://hackage.haskell.org/package/
    http://hdiff.luite.com/packages/archive/package/
  ];

  # Roy marples mirrors
  roy = [
    http://roy.marples.name/downloads/
    http://roy.aydogan.net/
    http://cflags.cc/roy/
  ];

  # Sage mirrors (http://www.sagemath.org/mirrors.html)
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

  # MySQL mirrors
  mysql = [
    http://mysql.mirrors.pair.com/Downloads/
    http://cdn.mysql.com/Downloads/
  ];

  # OpenBSD mirrors
  openbsd = [
    http://openbsd.mirrors.pair.com/
    http://ftp.openbsd.org/pub/OpenBSD/
  ];
}
