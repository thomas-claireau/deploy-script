echo "Quel est le titre du dépot ?"
read title
echo "Une description pour le dépot ?"
read description
echo "Quel est le slug du dépot ?"
read slug
mkdir $slug
cd $slug

# Git Config
git init

git remote add origin https://github.com/thomas-claireau/$slug.git

while true; do
	read -p "Déploiement sur Cpanel ?" yn
	case $yn in
	[Yy]*)
		# On rajoute les actions de déploiement sur Cpanel
		git remote set-url --add --push origin https://github.com/thomas-claireau/$slug.git
		git remote set-url --add --push origin ssh://clth9110@thomas-claireau.fr/home/clth9110/repositories/$slug

		echo "Sous dossier ?"
		read sousdossier

		# Cpanel Config
		cat <<EOT >>.cpanel.yml
deployment:
	tasks:
		- export DEPLOYPATH=~/$sousdossier$slug
		- /bin/cp -R * \$DEPLOYPATH
		- \$DEPLOYPATH/build.sh 2>&1
EOT

		# Build Config
		cat <<EOT >>build.sh
#!/bin/bash
set -x

# Build script
cd ~/$sousdossier$slug
source ~/.bashrc
npm install
npm run build
EOT

		chmod +x build.sh

		# Create empty folder project in cpanel server
		ssh clth9110@thomas-claireau.fr <<EOF
cd ~/$sousdossier
mkdir $slug
exit
EOF
		break
		;;
	[Nn]*)
		break
		;;
	*) echo "Please answer yes or no." ;;
	esac
done

# Readme
cat <<EOT >>README.md
# $title
$description
EOT

# Git Actions
# git add .
# git commit -m "First commit"
# git push -u origin master

git checkout -b dev
# git push origin dev
