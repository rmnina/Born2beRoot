# Born2beRoot

Born2beRoot est un projet de l'école 42 portant sur la **configuration d'une machine virtuelle**, bien sûr sans GUI (où serait le fun ?). Il permet une immersion assez conséquente dans le domaine de l'administration système. Dans la mesure où j'ai fait ce projet ************3 FOIS************(une première fois sur mon PC perso, une seconde au propre à l'école et une troisième car ma VM s'est faite supprimer des serveurs de l'école……..), je me suis dit que ça valait bien au moins un petit résumé détaillé.

**!! DISCLAIMER !!**

Ce fichier n'est ******pas****** un guide de réalisation du projet, mais simplement un condensé de ce que j'y ai fait et appris, car je l'ai vraiment adoré et je suis déçue que, contrairement aux projets de code, il n'y en ait pas vraiment de trace. Il s'agit donc simplement d'un partage de mon apprentissage et du rendu de quelques parties sympas de mon Born2beRoot.

## 1 - Installation

J'ai choisi dans un premier temps de faire tourner ma machine sous ****Debian**** (12 “Bookworm”, dernière version en date de mon projet). L'alternative était **********************Rocky Linux**********************, mais cette distribution n'était pas trop recommandée pour les débutants (ce que je suis) alors je n'ai pas voulu jouer dans cette cour. L'installation de la machine, après allocation de taille / RAM, impliquait donc de télécharger et d'intégrer une image disque de la distribution choisie (*debian-12.0.0-amd64-netinst.iso*). Il s'agissait ensuite simplement de suivre les étapes de configuration :

- Paramétrage du langage et du fuseau horaire ;
- Choix du hostname, ici et selon les consignes du projet *jdufour42* (je pourrai le changer plus tard avec la commande suivante) :

```bash
sudo hostnamectl set-hostname [NEW_HOSTNAME]
```

- Mot de passe du super-utilisateur root;
- Création de l'user de la machine, ici et selon les consignes *******jdufour*******, ainsi que de son mdp. Il sera possible ensuite d'en créer un nouveau avec la commande :

```bash
sudo adduser
```

- Le partitionnement. Le projet nous demandait de créer une **partition primaire principale**, et une **partition logique chiffrée capable d'accueillir les volumes LVM.**
    - Comme j'ai décidé de faire les bonus, j'ai accordé à ma partition primaire /boot une taille équivalente à celle donnée en exemple du modèle de partitionnement du sujet, soit *500MB*. Je l'ai positionnée au début de mon schéma de partitions et ai défini le /boot comme mountpoint. Elle accueillera ainsi les fichiers statiques du programme de démarrage.
    - La seconde partition prenait le reste de l'espace libre et permettait d'accueillir mes volumes chiffrés. Il devait s'agir d'une **********************************partition logique**********************************. Puisque cette partition agissait comme une cloison pour mes volumes logiques et ne contiennait pas de données propres, je ne lui ai pas configuré pas de mountpoint. J'ai ainsi pu aller configurer mes volumes chiffrés dedans :
        - J'ai créé un mot de passe pour le chiffrement de mes volumes ;
        - J'ai configuré un **groupe de volumes LVMGroup** ;
        - J'ai ensuite créé et configuré mes 7 volumes demandés dans la partie bonus : ***/root, /home, /var, /srv, /tmp, /swap et /var/log***. Je leur ai attribué des tailles similaires à celles indiquées comme exemple dans le sujet bonus, et leur ai ensuite attribué les mountpoint correspondants.
- Pour finir, j'ai refusé l'installation de softwares supplémentaires pour ne laisser que le **programme de démarrage GRUB**.

Bon, ça c'était la partie la moins funky, d'autant que l'attente entre les différentes étapes du paramétrage m'a bien laissé le temps d'augmenter mes taux de caféine. Mais, j'ai enfin pu arriver à l'interface de mon petit système tout neuf, et le fun a pu commencer !

## 2 - Configuration

La première chose que j'ai faite, après un petit ****************apt update****************, c'est d'installer tout ce dont j'allais avoir besoin pour la partie mandatory (********sudo, ufw, openssh-server********), ainsi que quelques petits autres paquets utiles (comme ******vim****** par exemple). Je me suis ensuite attaquée aux différentes configurations requises par le sujet.

### 2. 1 - Politique de mots de passe

Le sujet demandait l'instauration d'une **politique de mots de passes forts**. J'ai téléchargé pour cela la librairie **libpam-pwquality** qui me permettait d'instaurer certaines règles absentes du ********pam-unix******** de base. Je l'ai inclue dans un fichier ***/etc/security/pwquality.conf*** et ai configuré les options suivantes :

```bash
difok=7 #le nouveau mdp doit contenir au moins 7 caractères différents de l'ancien
retry=3 #fixe à 3 le nombre maximum de tentatives de mdp
dcredit=-1 #le mdp doit contenir au moins un chiffre
ucredit=-1 #le mdp doit contenir au moins une majuscule
maxrepeat=3 #le mdp ne doit pas contenir plus de 3 caractères identiques consécutifs
usercheck=1 #le mdp ne doit pas contenir le nom de l'user
ENFORCE_FOR_ROOT #applique toutes les règles qui suivront à l'user root
```

Les règles d'expiration du mot de passe ont dû être configurées dans un autre fichier **/etc/login.defs**, avec les valeurs suivantes :

```bash
PASS_MAX_DAYS 30 #expiration tous les 30j
PASS_MIN_DAYS 2 #délai de 2j entre chaque changement de mdp
PASS_WARN_AGE 7 #alerte 7j avant l'expiration du mdp
```

Ces valeurs ont dû être enforcées par les commandes suivantes :

```bash
sudo chage -M30 -m2 -W7 [utilisateur/root]
```

Sans cela, elles ne se seraient appliquées qu'aux nouveaux utilisateurs, et non aux utilisateurs déjà existants.

### 2. 2 - SUDO

La commande sudo, qui permet à un utilisateur normal d'exécuter des commandes en tant que super-user, devait, elle aussi, s'accompagner de sécurités requises par le sujet. J'ai dû pour cela modifier le fichier *************************/etc/sudoers************************* grâce à l'éditeur ************visudo.************ Voici ce que j'y ai ajouté :

```bash
Default  passwd_tries=3 #fixe à 3 le nombre de tentatives de mdp
Default  badpass_message="yoyoyo wrong password bro" #permet de paramétrer un message de wrong passwd
Default  logfile="/var/log/sudo/sudo.log" #inscrit les utilisations de sudo dans le fichier indiqué
Default  log_input #journalise les commandes sudo
Default  log_output #journalise les sorties des commandes sudo
Default  requiretty #active le mode TTY
Default  securepath="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin" #limite les path utilisables par sudo
```

Il fallait aussi bien entendu que j'ajoute mon user au group sudo,

```bash
sudo usermod -aG sudo jdufour
```

Et que je lui donnes les permissions adéquates dans le fichier **************sudoers************** avec l'ajout de la ligne suivante :

```bash
jdufour  ALL=(ALL:ALL) ALL
```

### 2.3 - Configuration UFW et SSH

Pour configurer **UFW**, i.e. le **pare-feu** requis par le sujet, rien de plus simple, je n'ai eu qu'à taper ces commandes : 

```bash
sudo ufw enable #active le pare-feu UFW
sudo ufw allow [PORT] #autorise le port dont le numéro remplace [PORT]
sudo ufw status #permet de vérifier la liste des ports autorisés
```

Pour le SSH, il y avait une partie un peu plus “tricky” car le port demandé par le sujet était déjà utilisé par l'école (ce qui n'était pas le cas au moment de l'élaboration du sujet), j'ai donc dû faire une redirection depuis mes paramètres virtualbox vers un port inutilisé. Du reste, il me suffisait de télécharger **openssh-server**, et de modifier les lignes suivantes dans le fichier *****************/etc/ssh/sshd_config***************** :

```bash
Port [PORT] #indique au service ssh qu'il doit écouter le port [PORT]
PermitRootLogin no #interdit à l'user ROOT de se connecter en ssh
```

Puis :

```bash
sudo systemctl restart sshd
```

Et voilà, mon **service ssh était fonctionnel** et je pouvais m'y connecter depuis mon host avec :

```bash
ssh jdufour@localhost -p [PORT]
```

Au passage, je note aussi ici une commande qui m'a été super utile pour récupérer mon script et le balader entre mes machines virtuelles au gré de mes resets de projet : 

```bash
scp -P [PORT] [nom-du-fichier] [USER]@localhost
```

Elle m'a permis, **via ssh, de copier un fichier de ma machine host jusqu'à ma machine virtuelle**, ce qui m'a économisé un sacré temps de recopiage !

### 2.4 - Cron et script de monitoring

Le script monitoring c'était un peu la partie la plus galère parce que ça impliquait plein de commandes un peu obscures.

Du coup, je suis TRES fière de mon petit script, je ne le commenterai pas en détail car les noms des variables sont assez explicites mais je vais quand même détailler qqs commandes que je ne connaissais pas avant.

Du reste, ce script permettait (comme son nom l'indique) de **rendre état de l'utilisation de la vm, ainsi que de certaines activités en cours et enregistrées.**

```bash
#!/bin/bash

	physical_cpus=$(grep 'physical id' /proc/cpuinfo | uniq | wc -l) #"uniq" permet de supprimer les doublons en cas de sortie de plusieurs lignes identiques dans la commande précédente
	virtual_cpus=$(grep processor /proc/cpuinfo | uniq | wc -l)
	total_RAM=$(free -h | grep Mem | awk '{print $2}') #"free" permet d'afficher toutes les activités relatives à l'utilisation de la mémoire
	used_RAM=$(free -h | grep Mem | awk '{print $3}') #le flag "-h" de free permet de sortir des données "human readable". sans ce flag, les valeurs s'affichent en KB
	RAM_percentage=$(free -k | grep Mem | awk '{printf("%.2f%%"), $3 / $2 * 100}') #le flag -k sort le résultat en KB. Le "%.2f%%" est un format spécifique de printf qui affiche le résultat avec deux décimales et ajoute le symbole "%" à la fin pour indiquer qu'il s'agit d'un pourcentage
	total_disk=$(df -h --total | grep total | awk '{print $2}') #"df" stands for "disk free". "--total" affiche une ligne de résumé supplémentaire qui donne les totaux de l'espace utilisé et disponible sur tous les systèmes de fichiers montés
	used_disk=$(df -h --total | grep total | awk '{print $3}')
	disk_percentage=$(df -k --total | grep total | awk '{print $5}')
	CPU_load=$(top -bn1 | grep '^%Cpu' | cut -c 9- | xargs | awk '{printf("%.1f%%"), $1 + $3}') #"top" surveille les scripts en cours d'exécution. "-b" exécute top en mode batch, "n1" affiche les infos en une seule fois. "cut -c 9-" isole les caractères à partir du 9ème. xargs facilite le transfert des résultats au pipe
	last_reboot=$(who -b | awk '{print($3 " " $4)}')
	lvm=$(lsblk | grep lvm | wc -l | awk '{if ($1){print("yes"); exit} else print "no"}')
	connections=$(grep TCP /proc/net/sockstat | awk '{print $3}')
	connected_users=$(who | wc -l)
	ipv4=$(hostname -I | awk '{print $1}')
	MAC=$(ip link show | grep link/ether | awk '{print $2}')
	sudo=$(cat /var/log/sudo/sudo.log | grep -c COMMAND)

	wall #"wall" permet de display son contenu sur les écrans de tous les utilisateurs connectés sur la VM
"

	 __   __  _______  __    _  ___   _______  _______  ______    ___   __    _  _______ 
	|  |_|  ||       ||  |  | ||   | |       ||       ||    _ |  |   | |  |  | ||       |
	|       ||   _   ||   |_| ||   | |_     _||   _   ||   | ||  |   | |   |_| ||    ___|
	|       ||  | |  ||       ||   |   |   |  |  | |  ||   |_||_ |   | |       ||   | __ 
	|       ||  |_|  ||  _    ||   |   |   |  |  |_|  ||    __  ||   | |  _    ||   ||  |
	| ||_|| ||       || | |   ||   |   |   |  |       ||   |  | ||   | | | |   ||   |_| |
	|_|   |_||_______||_|  |__||___|   |___|  |_______||___|  |_||___| |_|  |__||_______|	
	
	_____________________________________________________________________________________

	#	ARCHITECTURE: $(uname -srvmo)
	#	CPU physical: $physical_cpus
	#	vCPU: $virtual_cpus
	#	Memory Usage: $used_RAM/$total_RAM ($RAM_percentage)
	#	Disk Usage: $used_disk/$total_disk ($disk_percentage)
	#	CPU load: $CPU_load
	#	Last boot: $last_reboot
	#	LVM use: $lvm
	#	Connections TP: $connections ESTABLISHED
	#	User log: $connected_users
	#	Network: IP $ipv4 ($MAC)
	#	Sudo: $sudo cmd 
	_____________________________________________________________________________________"

#		                      /^--^\     /^--^\     /^--^\
#		                      \____/     \____/     \____/
#		                     /      \   /      \   /      \
#		                    |        | |        | |        |
#		                     \__  __/   \__  __/   \__  __/
#		|^|^|^|^|^|^|^|^|^|^|^|^\ \^|^|^|^/ /^|^|^|^|^\ \^|^|^|^|^|^|^|^|^|^|^|^|
#		| | | | | | | | | | | | |\ \| | |/ /| | | | | | \ \ | | | | | | | | | | |
#		| | | | | | | | | | | | / / | | |\ \| | | | | |/ /| | | | | | | | | | | |
#		| | | | | | | | | | | | \/| | | | \/| | | | | |\/ | | | | | | | | | | | |
#		#########################################################################
#		| | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |
#		| | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |
#
#		Art by Marcin Glinski (https://www.asciiart.eu/animals/cats)
```

```bash
*/10 * * * * bash /root/monitoring.sh
```

C'est tout ce que je voulais raconter pour la partie obligatoire. J'ai volontairement éclipsé certaines parties un peu redondantes comme la création de groupes, les commandes de manipulation de groupes et d'utilisateurs, c'était intéressant et utile à connaître mais c'était pas très folie folie. Du coup, go passer sur la partie que j'ai préférée : les BONUS!

## 3 - Les bonus !!!!!

Le premier bonus consistait juste à **reproduire un modèle de partition spécifique** au moment de la configuration. J'en ai déjà parlé dans cette partie donc je ne reviendrai pas là dessus, je vais juste traiter les deux autres.

### 3.1 - Le site Wordpress

L'installation du site Wordpress m'a CASSE LA TETE et je détaillerai pourquoi plus tard, mais je me suis éclatée et j'ai appris plein de trucs. Le sujet imposait d'héberger le site sur un **serveur Lighttpd** et grâce à une **database MariaDB**, avec un supplément **modules PHP**. Leur installation ne m'a pas posé de souci, mais pour faire tourner le site Wordpress ça a été la galère. Bon, chaque chose en son temps.

Déjà, la **configuration de Lighttpd** a juste impliqué dans un premier temps de changer le path des fichiers source pour accéder aux fichiers de config wordpress (puis à tous ceux qui seront créés avec le site), et le port qui sera utilisé pour la connexion. 

```bash
server.document-root    = "/var/www/html/wordpress/"
server.port             = 8080
```

Il fallait bien entendu s'assurer que les **droits du dossier** étaient appropriés, et dans le cas contraire lui balancer un petit chmod. Il était également indispensable d'autoriser le port 8080 par UFW.

La **configuration de MariaDB** était assez intuitive aussi car plus ou moins guidée, et MariaDB possède d'ailleurs son propre interface de commandes dans lequel on peut entrer en tapant cette ligne : 

```bash
mysql -u [USER]
```

Une fois qu'on est dedans, on peut lui demander un peu tout ce qu'on veut à condition de bien le syntaxer. Par exemple, pour **créer une base de données et donner à mon nouvel utilisateur des droits dessus**, j'ai écrit mon instruction ainsi : 

```bash
CREATE DATABASE [NAME];
GRANT ALL ON [NAME].* TO '[USER]'@'localhost' IDENTIFIED BY '[PASSWORD]' WITH GRANT OPTION;
```

Avec des bons points-virgule que j'oubliais tout le temps en fin de ligne et sans lesquels je me retrouvais avec un invite de commande pas très coopératif, comme quoi le C ne m'a rien appris en fait…

Bon, pour la configuration de la database que Wordpress utilisera, sur ma première VM j'avais un peu tout trifouillé dans les fichiers de conf, sur mes VM suivantes j'ai juste géré tout ça directement via **l'interface de config Wordpress** qui de toute manière invite à compléter les informations manquantes (et avec un visu un peu plus user friendly…). J'ai juste assuré mes arrières en autorisant par UFW le port 3306 utilisé par MariaDB.

Je n'avais plus qu'à me rendre sur :

```bash
http://127.0.0.1:8080
```

Pour voir le miracle opérer…

…et NON ma cocotte ! Car là où j'ai bien galéré, c'est pour capter **quels modules PHP ajouter et comment les configurer**. Mon site ne marchait pas DU TOUT pendant un bon moment, puis après pas mal de bricolage se contentait de me télécharger les fichiers source wordpress sans daigner les afficher. 

Il m'a fallu un moment et maintes recherches dans les tréfonds d'internet pour capter que je devais installer le module ***php8.2-fastcgi,*** et signaler à mon serveur qu'il devait s'en servir en ajoutant cette ligne dans son fichier de conf : 

```bash
server.modules = {
        "mod_fastcgi",
}
```

Le tout évidemment accompagné de quarante mille restarts du serveur et des modules php en veux-tu en voilà. Mais là pour le coup j'ai enfin pu accéder à mon site, que j'ai bien entendu allègrement instrumentalisé pour ma propagande usuelle.



https://github.com/rmnina/Born2beRoot/assets/118455014/f3641c99-6867-4a33-8a38-633af238798a



### 3.2 - Mon serveur Minecraft

Pour le deuxième bonus, le sujet proposait **d'installer un service supplémentaire “au choix”** sous condition d'en justifier l'intérêt. Quel service plus intéressant alors qu'un serveur Minecraft ? 🙂 (en vrai et plus sérieusement c'est carrément optimal en matière de ressources et de sécurité de faire tourner ça sur VM et surtout s'il est voué à être accessible en ligne. Ce qui n'est pas mon cas mais ça avait quand même sa pertinence !).

J'avais déjà plus ou moins vu comment ces serveurs se configuraient mais je n'en avais jamais créé un moi-même de A à Z. Au final ce n'était pas très sorcier à condition de **bien installer TOUTES les dépendances de Java**, indispensables pour faire tourner correctement la machine. 

Il s'agissait simplement ensuite d'autoriser via UFW le port 25565 utilisé par défaut par le serveur, comme indiqué sur le fichier de config server.properties : 

```bash
query.port=25565
```

Et il n'y avait ensuite qu'à **lancer l'exécutable server.jar** avec cette commande : 

```bash
java -Xmx1024M -Xms1024M -jar server.jar nogui
```

Les -Xmx1024M et -Xms1024M limitant la RAM utilisable par le serveur (RAM que j'ai d'ailleurs dû augmenter dans les config Virtualbox de ma VM sans quoi le serveur avait du mal…) ; et le nogui servant à préciser que je ne voulais pas de graphical user interface.

![Screenshot_from_2023-07-29_00-22-53](https://github.com/rmnina/Born2beRoot/assets/118455014/2af5bba2-e845-4e30-be91-71c4a1065f9e)

![Screenshot_from_2023-07-29_00-23-18](https://github.com/rmnina/Born2beRoot/assets/118455014/815a85d8-ace1-485b-a461-732360d706cf)

![Screenshot_from_2023-07-29_00-24-47](https://github.com/rmnina/Born2beRoot/assets/118455014/ba75228e-387b-4d86-a082-6cb78be4178d)


Et voilà le travail !! 

## Conclusion

Pour finir sur ce petit récap je me suis vraiment éclatée à faire et refaire (quand bien même j'ai bien râlé à la troisième fois…) ce projet. Ca a quand même eu du bon toutes ces histoires de reset de VM parce que du coup je me suis bien familiarisée avec le shell, et même de retour sur le C ça m'est bien utile d'être à l'aise avec la ligne de commande. 

Je suis aussi contente d'avoir écrit ce résumé car, encore une fois, ça me rendait un peu triste de ne pas avoir d'autres traces que mon script sur ce projet. J'espère qu'il n'est pas assez exhaustif pour être considéré comme un step-to-step, mais quand même assez détaillé pour être clair et partager un peu de ce que j'ai appris.

Ok bye !

![Capture d’écran 2023-07-29 à 00 33 51](https://github.com/rmnina/Born2beRoot/assets/118455014/d5fd69f9-e960-4773-8d0c-552cbb9d1b66)
