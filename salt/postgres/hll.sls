{% set VERSION = '2.10.0' %}

download_hll:
  archive.extracted:
    - name: /home/vagrant/hll
    - source: https://github.com/aggregateknowledge/postgresql-hll/archive/v{{ VERSION }}.tar.gz
    - source_hash: md5=9dbf66901570105a8c671d765799a6d0
    - user: vagrant
    - archive_format: tar

make_hll:
  cmd.run:
    - name: make
    - cwd: /home/vagrant/hll/postgresql-hll-{{ VERSION }}
    - creates: /home/vagrant/hll/postgresql-hll-{{ VERSION }}/hll.o
    - require:
      - pkg: install_postgres_headers
      - archive: download_hll

construct_hll_install_dir:
  file.directory:
    - name: /tmp/hll
    - user: vagrant

install_hll:
  cmd.run:
    - name: make install DESTDIR=/tmp/hll
    - cwd: /home/vagrant/hll/postgresql-hll-{{ VERSION }}
    - creates: /tmp/hll/usr

package_hll:
  cmd.run:
    - name: fpm -s dir -t deb -n "postgres-hll" -v {{ VERSION }} -C /tmp/hll usr
    - creates: /vagrant/postgres-hll_{{ VERSION }}_amd64.deb
    - cwd: /vagrant
    - user: vagrant
    - require:
      - gem: fpm
