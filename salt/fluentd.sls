# version to download from official fluent-bit releases
{% set MINOR_VERSION = '0.11' %}

# git commit hash used to download repo, takes precendence over official releases
{% set COMMIT_HASH = 'e536db510940172e10258e6c668ee51c0e8a6d9f' %}

# version to assign to build artifact
{% set VERSION = '0.12.0.alpha' %}

download_fluentbit:
  archive.extracted:
    - name: /home/vagrant
    {% if COMMIT_HASH is defined %}
    - source: https://github.com/fluent/fluent-bit/archive/{{ COMMIT_HASH }}.zip
    {% else %}
    - source: http://fluentbit.io/releases/{{ MINOR_VERSION }}/fluent-bit-{{ VERSION }}.tar.gz
    {% endif %}
    - skip_verify: True
    - user: vagrant

{% if COMMIT_HASH is defined %}
# rename destination folder to something more specific and readable
rename_source_directory:
  file.rename:
    - name: /home/vagrant/fluent-bit-{{ VERSION }}
    - source: /home/vagrant/fluent-bit-{{ COMMIT_HASH }}
{% endif %}

construct_build_dir:
  file.directory:
    - name: /home/vagrant/fluent-bit-{{ VERSION }}/build
    - user: vagrant

run_cmake:
  cmd.run:
    - name: cmake ../
    - cwd: /home/vagrant/fluent-bit-{{ VERSION }}/build
    - user: vagrant
    - creates: /home/vagrant/fluent-bit-{{ VERSION }}/build/Makefile

make_fluentbit:
  cmd.run:
    - name: make
    - cwd: /home/vagrant/fluent-bit-{{ VERSION }}/build
    - user: vagrant
    - creates: /home/vagrant/fluent-bit-{{ VERSION }}/build/bin/fluent-bit

create_install_dir:
  file.directory:
    - name: /tmp/fluentbit
    - user: vagrant
    - clean: true

install_fluentbit:
  cmd.run:
    - name: make install DESTDIR=/tmp/fluentbit
    - cwd: /home/vagrant/fluent-bit-{{ VERSION }}/build
    - creates: /tmp/fluentbit/usr/local/etc/fluent-bit/parsers.conf

copy_upstart_service:
  file.managed:
    - name: /tmp/fluentbit/etc/init/fluent-bit.conf
    - source: salt://files/fluentbit/etc/init/fluent-bit.conf
    - makedirs: True
    - user: vagrant

copy_systemd_service:
  file.managed:
    - name: /tmp/fluentbit/lib/systemd/system/fluent-bit.service
    - source: salt://files/fluentbit/lib/systemd/system/fluent-bit.service
    - makedirs: True
    - user: vagrant

package_fluentbit:
  cmd.run:
    - name: fpm -s dir -t deb -n "fluentbit" -v {{ VERSION }} -C /tmp/fluentbit
    - creates: /vagrant/fluentbit_{{ VERSION }}_amd64.deb
    - cwd: /vagrant
    - user: vagrant
    - require:
      - gem: fpm
