{% set VERSION = '1.7.2-20161209' %}
{% set GIT_HASH = '61b320ad547cc71219786f9fa82cd548debb13d8' %}

clone_pgbouncer:
  git.latest:
    - name: https://github.com/pgbouncer/pgbouncer.git
    - target: /home/vagrant/pgbouncer
    - user: vagrant
    - rev: {{ GIT_HASH }}
    - submodules: True

install_dependencies:
  pkg.installed:
    - pkgs:
      - libevent-dev
      - libssl-dev
      - libc-ares-dev
      - autoconf
      - automake
      - libtool
      - autoconf-archive
      - python-docutils
      - pkg-config

make_pgbouncer:
  cmd.run:
    - name: |
        ./autogen.sh
        ./configure
        make
    - cwd: /home/vagrant/pgbouncer
    - creates: /home/vagrant/pgbouncer/pgbouncer

install_pgbouncer:
  cmd.run:
    - name: make install DESTDIR=/tmp/pgbouncer
    - cwd: /home/vagrant/pgbouncer
    - creates: /tmp/pgbouncer/usr

package_pgbouncer:
  cmd.run:
    - name: fpm -s dir -t deb -n "pgbouncer" -d "libc-ares-dev" -v {{ VERSION }} -C /tmp/pgbouncer usr
    - creates: /vagrant/pgbouncer_{{ VERSION }}_amd64.deb
    - cwd: /vagrant
    - user: vagrant
    - require:
      - gem: fpm
