{% set VERSION = '0.0.1' %}
# No version for session_analytics, use this as a crude release version

make_session_analytics:
  cmd.run:
    # Don't trust the built code since we're simply linking through to Heap. Sigh
    - name: make clean && make
    - cwd: /home/vagrant/session_analytics
    - require:
      - pkg: install_postgres_headers
      - archive: download_hll
    - onlyif:
      - test -d /home/vagrant/session_analytics

construct_session_analytics_install_dir:
  file.directory:
    - name: /tmp/session_analytics
    - user: vagrant
    - onlyif:
      - test -d /home/vagrant/session_analytics

install_session_analytics:
  cmd.run:
    - name: make install DESTDIR=/tmp/session_analytics
    - cwd: /home/vagrant/session_analytics
    - creates: /tmp/session_analytics/usr
    - onlyif:
      - test -d /home/vagrant/session_analytics

package_session_analytics:
  cmd.run:
    - name: fpm -s dir -t deb -n "postgres-session-analytics" -v {{ VERSION }} -C /tmp/session_analytics usr
    - creates: /vagrant/postgres-session-analytics_{{ VERSION }}_amd64.deb
    - cwd: /vagrant
    - user: vagrant
    - require:
      - gem: fpm
    - onlyif:
      - test -d /home/vagrant/session_analytics
