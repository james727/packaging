{% set VERSION = '0.0.1' %}
# JSON build doesn't version the codebase, use this as a crude release version

download_json_build:
  archive.extracted:
    - name: /home/vagrant/json_build
    - source: https://github.com/pgexperts/json_build/archive/master.zip
    - source_hash: md5=00ea45d2ffa2e1fc229b0b605e183477
    - user: vagrant
    - archive_format: zip

make_json_build:
  cmd.run:
    - name: make
    - cwd: /home/vagrant/json_build/json_build-master
    - creates: /home/vagrant/json_build/json_build-master/json_build.o
    - require:
      - pkg: install_postgres_headers
      - archive: download_hll

construct_json_build_install_dir:
  file.directory:
    - name: /tmp/json_build
    - user: vagrant

install_json_build:
  cmd.run:
    - name: make install DESTDIR=/tmp/json_build
    - cwd: /home/vagrant/json_build/json_build-master
    - creates: /tmp/json_build/usr

package_json_build:
  cmd.run:
    - name: fpm -s dir -t deb -n "json_build" -v {{ VERSION }} -C /tmp/json_build usr
    - creates: /vagrant/json-build_{{ VERSION }}_amd64.deb
    - cwd: /vagrant
    - user: vagrant
    - require:
      - gem: fpm

