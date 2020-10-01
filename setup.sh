#!/bin/bash
set -e
set -u

apt-get update
apt-get install screen

wget https://github.com/jgm/pandoc/releases/download/2.10.1/pandoc-2.10.1-1-amd64.deb
dpkg -i pandoc-*.deb
rm -rf pandoc-*.deb

pandoc --version

cd /usr/src/redmine

# Enable HTML in redmine
sed -iE 's/filter_html\s*=>\s*true/filter_html => false/' "lib/redmine/wiki_formatting/markdown/formatter.rb"

echo "Restart redmine! We enabled HTML in markdown!"
echo "Use 'screen -S session1' for creating a screen session!"
