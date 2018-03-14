include:
  - .hll
  - .json_build
  - .session_analytics
  - .pgbouncer
  - .intpair

add_pgdg_repo:
  pkgrepo.managed:
    - humanname: Postgres Developer Group
    - name: deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main
    - key_url: https://www.postgresql.org/media/keys/ACCC4CF8.asc
    - file: /etc/apt/sources.list.d/pgdg.list

install_postgres_headers:
  pkg.installed:
    - pkgs:
      - postgresql-server-dev-10
    - require:
      - pkgrepo: add_pgdg_repo

