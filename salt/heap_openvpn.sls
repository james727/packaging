{% set VERSION = '0.0.2' %}

github_host_key:
  cmd.run:
    - name: 'ssh-keyscan -t rsa github.com > /home/vagrant/.ssh/known_hosts'

heap_openvpn_repo:
  git.latest:
    - name: git@github.com:heap/heap_openvpn.git
    - target: /home/vagrant/heap_openvpn
    - user: vagrant
    - force_fetch: True
    - rev: 'master'

make_heap_openvpn:
  cmd.run:
    - name: make
    - cwd: /home/vagrant/heap_openvpn/
    - creates:
        - /home/vagrant/heap_openvpn/heap_openvpn.so

construct_heap_install_dir:
  file.directory:
    - name: /tmp/heap
    - user: vagrant

install_heap:
  cmd.run:
    - name: make install DESTDIR=/tmp/heap
    - cwd: /home/vagrant/heap_openvpn/
    - creates: /tmp/heap/opt/heap

package_heap:
  cmd.run:
    - name: fpm -s dir -t deb -n "heap-openvpn" -v {{ VERSION }} -C /tmp/heap opt
    - creates: /vagrant/heap-openvpn_{{ VERSION }}_amd64.deb
    - cwd: /vagrant
    - user: vagrant
    - require:
      - gem: fpm
