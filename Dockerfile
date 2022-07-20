FROM ubuntu:22.04
WORKDIR /opt
ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i 's/# deb-src/deb-src/' /etc/apt/sources.list &&\
    apt-get update && apt-get install --yes --no-install-recommends  \
    apt-transport-https\
    ca-certificates\
    build-essential \
    autoconf \
    gcc-10 \
    git \
    pkg-config \
    libgnutls28-dev \
    libasound2-dev \
    libacl1-dev \
    libgtk-3-dev \
    libgpm-dev \
    liblockfile-dev \
    libm17n-dev \
    libotf-dev \
    libsystemd-dev \
    libjansson-dev \
    libgccjit-11-dev \
    libgif-dev \
    librsvg2-dev  \
    libxml2-dev \
    libxpm-dev \
    libtiff-dev \
    libjbig-dev \
    libncurses-dev\
    liblcms2-dev\
    libwebp-dev\
    libsqlite3-dev\
    texinfo


# Clone emacs
RUN update-ca-certificates \
#    && git clone --depth 1 https://git.savannah.gnu.org/git/emacs.git emacs \
    && git clone --depth 1 https://github.com/flatwhatson/emacs -b pgtk-nativecomp emacs \
    && mv emacs/* .

# Build
ENV CC="gcc-11"
RUN ./autogen.sh && ./configure \
    --prefix "/usr/local" \
    --with-gameuser=:games \
    --with-sound=alsa \
    --with-modules \
    --with-x-toolkit=gtk3 \
    --with-cairo \
    --with-native-compilation \
    --with-pgtk \
    --with-json \
    --with-gnutls  \
    --with-rsvg  \
    --with-mailutils \
    --without-xwidgets \
    --without-compress-install \
    --without-gconf \
    --without-gsettings \
    --without-m17n-flt \
    --enable-autodepend \
    --enable-link-time-optimization \
    CFLAGS="-O2 -pipe"

RUN make NATIVE_FULL_AOT=1 -j $(nproc)

# Create package
RUN EMACS_VERSION=$(sed -ne 's/AC_INIT(GNU Emacs, \([0-9.]\+\), .*/\1/p' configure.ac) \
    && make install prefix=/opt/emacs-gcc-pgtk_${EMACS_VERSION}/usr/local \
    && mkdir emacs-gcc-pgtk_${EMACS_VERSION}/DEBIAN && echo "Package: emacs-gcc-pgtk\n\
Version: ${EMACS_VERSION}\n\
Section: base\n\
Priority: optional\n\
Architecture: amd64\n\
Depends: libgif7, libotf1, libgccjit0, libm17n-0, libgtk-3-0, librsvg2-2, libtiff5, libjansson4, libacl1, libgmp10, libwebp7, libsqlite3-0\n\
Maintainer: konstare\n\
Description: Emacs with native compilation and pure GTK\n\
    --with-gameuser=:games \n\
    --with-sound=alsa \n\
    --with-modules \n\
    --with-x-toolkit=gtk3 \n\
    --with-cairo \n\
    --with-native-compilation \n\
    --with-pgtk \n\
    --with-json \n\
    --with-gnutls  \n\
    --with-rsvg  \n\
    --with-mailutils \n\
    --without-xwidgets \n\
    --without-compress-install \n\
    --without-gconf \n\
    --without-gsettings \n\
    --without-m17n-flt \n\
    --enable-autodepend \n\
    --enable-link-time-optimization \n\
 CFLAGS='-O2 -pipe'" \
    >> emacs-gcc-pgtk_${EMACS_VERSION}/DEBIAN/control \
    && dpkg-deb --build emacs-gcc-pgtk_${EMACS_VERSION} \
    && mkdir /opt/deploy \
    && mv /opt/emacs-gcc-pgtk_*.deb /opt/deploy
