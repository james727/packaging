# Heap packaging
Builds deb packages for things not publicly available.

# Why does this exist?
In short we should be installing any dependency via a package manager of some description, but some projects don't provide deb packages. This builds simple packages for those projects that we can host on an internal apt repository.

Installing via a package manager means that we:
* Get nice versioning and simplified installs via configuration management
* More predicatable instance creation, no download links are dead or codebases no longer compiling
* Less need for development tools and compilers on production instances

# How do I use this?
The project aims to create a vagrant VM for any common packaging requirements. These VM's should build any packages during the provisioning stage, i.e users should be able to run `vagrant up <machine> && vagrant destroy <machine>` and have all packages available within the root directory.

A `tester` vagrant machine is available as a clean image for testing package installs.

Packaging machines currently available:
* bosun
* postgres (builds a range of postgres extensions)

`vagrant up` might fail with error on `fpm` gem install. In this case, SSH into the failing box and run `sudo gem install fpm --no-rdoc --no-ri` manually.

## Pushing updated packages to the heap repo

Getting the GPG key used for signing the repository manifests:
- `brew install gpg`
- The contents of the gpg key, and its passphrase are stored in vault under `secret/apt_gpg_key`. Refer to https://paper.dropbox.com/doc/Vault-Operations-Manual--ALTMb1umEuCN4jIvBUwl6Os~Ag-Kzl3ydBffSVb8rWSP8ONM for reading secrets from vault.
- Copy the gpg contents from (and including) `-----BEGIN PGP PRIVATE KEY BLOCK-----` to (and including) `-----END PGP PRIVATE KEY BLOCK-----` to a local file.
- The passphrase for the gpg key is at the bottom of the vault output.
- Run `gpg --import <path-to-key>`. You will need to enter the passphrase.

The `upload.sh` script should be used to push any updated packages to an S3 backed apt repository. To use it:
- install [deb-s3](https://github.com/krobertson/deb-s3)
- `export BUCKET=heap-apt-repo` (the S3 bucket holding the apt repo)
- `export GPG_KEY=02F09197` (the ID of the above gpg key - essentially a hash of the key contents)
- `../infrastructure/terraform/getTemporaryCredentials.coffee --readwrite` (from the http://github.com/heap/infrastructure repo, make sure that you have terraform installed and setup)
- `./upload.sh <path-to-file>`
- Enter the gpg passphrase when prompted.

Pushing packages to Heap apt repository does not guarantee that the latest version will be installed by salt, although it is possible to set this up.
Please refer to [heap/infrastructure](https://github.com/heap/infrastructure) for details.

## Viewing current packages
You may want to list out the packages currently present in the Heap apt repository.
- If you don't have temporary aws credentials, run `getTemporaryCredentials.coffee` as outlined above.
- `export BUCKET=heap-apt-repo`
- `deb-s3 list --bucket $BUCKET`

# Uploading nodejs point version
It's not possible to install arbitrary nodejs versions using apt, since only some node versions are kept in the apt repositories.
However, builds of all versions are archived and available:
- https://deb.nodesource.com/node_4.x/pool/main/n/nodejs/
- https://deb.nodesource.com/node_6.x/pool/main/n/nodejs/
- https://deb.nodesource.com/node_8.x/pool/main/n/nodejs/
- etc

It isn't necessary to provision and build the specific version since these are already built.
For example, to upload node 6.14.3:
- `curl -o nodejs_6.14.3-1nodesource1_amd64.deb https://deb.nodesource.com/node_6.x/pool/main/n/nodejs/nodejs_6.14.3-1nodesource1_amd64.deb`
- Then use `upload.sh` script as described above.

# How do I add a new package?
If your package doesn't fit nicely into one of the existing vagrant machines then you'll need to create a new instance. Check the `Vagrantfile` for the current usage. Each new machine must have the hostname set so that it can be targetted via Salt, you'll need to add this targetting to `salt/top.sls`.

Assuming you have a build host available, any steps required to package the new dependency should be added to the salt formulas for that build host. These will likely include: downloading sources or binaries, setting up install directory structures and packaging those structures via [fpm](https://github.com/jordansissel/fpm).
