{% set VERSION = '2.10.2' %}

download_hll:
  archive.extracted:
    - name: /home/vagrant/hll
    - source: https://github.com/aggregateknowledge/postgresql-hll/archive/v{{ VERSION }}.tar.gz
    - source_hash: md5=0bdb0b5fa42c15de795059c598458b1a
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
    - name: fpm -s dir -t deb -n "postgres10-hll" -v "{{ VERSION }}" -C /tmp/hll usr
    - creates: /vagrant/postgres10-hll_{{ VERSION }}_amd64.deb
    - cwd: /vagrant
    - user: vagrant
    - require:
      - gem: fpm
