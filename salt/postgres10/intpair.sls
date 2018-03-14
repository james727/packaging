{% set VERSION = '0.0.1' %}

download_intpair:
  archive.extracted:
    - name: /home/vagrant/pg_intpair
    - source: https://github.com/heap/pg_intpair/archive/v{{ VERSION }}.tar.gz
    - source_hash: md5=55acd717e4bdb2f585a11a36ba14a32b
    - user: vagrant
    - archive_format: tar

make_intpair:
  cmd.run:
    - name: make --always-make USE_PGXS=1
    - cwd: /home/vagrant/pg_intpair/pg_intpair-{{ VERSION }}
    - creates: /home/vagrant/pg_intpair/pg_intpair-{{ VERSION }}/intpair.o
    - require:
      - pkg: install_postgres_headers
      - archive: download_intpair

construct_intpair_install_dir:
  file.directory:
    - name: /tmp/pg_intpair
    - user: vagrant

install_intpair:
  cmd.run:
    - name: make install USE_PGXS=1 DESTDIR=/tmp/pg_intpair
    - cwd: /home/vagrant/pg_intpair/pg_intpair-{{ VERSION }}
    - creates: /tmp/pg_intpair/usr

package_intpair:
  cmd.run:
    - name: fpm -s dir -t deb -n "postgres10-intpair" -v "{{ VERSION }}" -C /tmp/pg_intpair usr
    - creates: /vagrant/postgres10-intpair_{{ VERSION }}_amd64.deb
    - cwd: /vagrant
    - user: vagrant
    - require:
      - gem: fpm
