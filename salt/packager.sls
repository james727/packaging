install_base_packages:
  pkg.installed:
    - pkgs:
      - ruby-dev
      - gcc
      - g++
      - make
      - git
      - cmake

install_fpm:
  gem.installed:
    - name: fpm
    - require:
      - pkg: install_base_packages

