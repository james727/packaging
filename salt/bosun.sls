create_build_dir:
  file.recurse:
    - name: /tmp/bosun
    - source: salt://files/bosun
    - user: vagrant
    - group: vagrant

download_bosun:
  file.managed:
    - name: /tmp/bosun/usr/local/bin/bosun
    - source: https://github.com/bosun-monitor/bosun/releases/download/0.5.0-rc1/bosun-linux-amd64
    - source_hash: md5=d9ea0e87224f498a5b77597b0f447d46
    - user: vagrant
    - makedirs: True
    - dir_mode: 755
    - mode: 755

package_bosun:
  cmd.run:
    - name: fpm -s dir -t deb -n "bosun" -v 0.5.0 -C /tmp/bosun --after-install /tmp/bosun/after-install.sh etc usr
    - creates: /vagrant/bosun_0.5.0_amd64.deb
    - cwd: /vagrant
    - user: vagrant
    - require:
      - gem: fpm
