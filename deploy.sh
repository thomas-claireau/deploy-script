#!/bin/bash

echo "Quel est le titre du dépot ?"
read title
echo "Une description pour le dépot ?"
read description
echo "Quel est le slug du dépot ?"
read slug
echo "A quel niveau créer le repository local ?"
read path

cd $path
if (( $? )) ; then exit ; fi

mkdir $slug
if (( $? )) ; then exit ; fi

cd $slug
if (( $? )) ; then exit ; fi

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

		echo "chemin et avec slash à la fin (sans le dossier final)"
		read chemin

		echo "nom du dossier final sur le serveur (sans slash)"
		read dossier_final

# Cpanel Config
cat <<EOT >>.cpanel.yml
deployment:
  tasks:
    - export DEPLOYPATH=~/$chemin$dossier_final
    - /bin/cp -R * \$DEPLOYPATH
    - \$DEPLOYPATH/build.sh 2>&1
EOT

# Build Config
cat <<EOT >>build.sh
#!/bin/bash
set -x

# Build script
cd ~/$chemin$dossier_final
source ~/.bashrc
EOT

		# Create empty folder project in cpanel server (+ create empty build.sh executable)
		ssh clth9110@thomas-claireau.fr <<EOF
cd ~/$chemin
mkdir $dossier_final
cd $dossier_final
touch build.sh
chmod +x build.sh
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
git add .
git commit -m "First commit"
git push -u origin master

# git checkout -b dev
# git push origin dev
