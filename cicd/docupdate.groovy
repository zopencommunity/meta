# Update Progress and Json in documentation
git clone git@github.com:ZOSOpenTools/meta.git meta_update
cd meta_update
python3 tools/getbinaries.py
git config --global user.email "zosopentools@ibm.com"
git config --global user.name "ZOS Open Tools"
git add docs/*.md
git add docs/images/*.png
git add docs/api/*
python3 tools/create_release_cache.py --verbose --output-file docs/api/zopen_releases.json
git commit -m "Updating docs/apis"
git pull --rebase
git push origin
