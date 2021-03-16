desc=`echo -n $1`

cd themes/hugo-theme-cole &&
npm run build &&
git add . &&
git commit -m "$desc" &&
git push &&
git push --tags &&
cd ../../ &&
hugo &&
git add . &&
git commit -m "$desc" &&
git push
