# webOS Launcher

Un écran d'accueil façon Apple TV pour les TV LG webOS, installé et piloté par un add-on
Home Assistant. Le bouton **Home** de la télécommande ouvre ce launcher à la place de l'accueil LG.

![Le launcher sur une LG OLED](docs/screenshot.jpg)

Rien n'est rooté : l'app passe par le **Developer Mode** officiel de LG, les mises à jour firmware
continuent de fonctionner, et supprimer l'app Developer Mode retire tout.

## Ce que fait l'add-on

- Lit les apps, icônes et entrées HDMI de la TV, empaquette le launcher et l'installe.
- Surveille l'app au premier plan : dès que l'accueil LG apparaît, il ouvre le launcher par-dessus.
  Appuyer deux fois sur Home en moins de 3 s reste sur l'accueil LG (pour ses menus).
- Prolonge la session Developer Mode chaque semaine (sinon elle expire après 1000 h), de préférence
  entre 3 h et 5 h du matin.

Nécessite Home Assistant OS ou Supervised (add-ons), pas HACS.

## Installation

1. Créer un compte gratuit sur [webostv.developer.lge.com](https://webostv.developer.lge.com).
2. Sur la TV, installer **Developer Mode** depuis le LG Content Store et se connecter.
   Activer **Dev Mode Status** (la TV redémarre), rouvrir l'app et activer **Key Server**.
   Noter l'**adresse IP** et la **Passphrase** affichées.
3. Dans Home Assistant : **Paramètres → Modules complémentaires → Boutique → ⋮ → Dépôts**, ajouter
   `https://github.com/k-bres/webos-ha-launcher`, puis installer **webOS Launcher**.
4. Dans l'onglet **Configuration**, renseigner `tv_host` (IP de la TV) et `passphrase`.
   Démarrer l'add-on TV allumée et accepter la demande « autoriser cet appareil ? » sur la TV.

Optionnel : sur le launcher, maintenir une touche chiffre de la télécommande pour l'y associer
(ouverture en un appui, sans passer par l'accueil LG).

| Option | Rôle |
|---|---|
| `tv_host` | IP de la TV |
| `passphrase` | Passphrase de l'app Developer Mode |
| `install_on_start` | Resynchronise et réinstalle le launcher à chaque démarrage (défaut `true`). Si la TV est éteinte, réessaie toutes les 2 min. |

**Redémarrer** l'add-on après avoir installé ou supprimé des apps sur la TV.

## Configurer le launcher

Le fichier est `/addon_configs/<id>_webos_vibehack/config.js` (add-on File editor ou Samba).
Il est créé au premier démarrage à partir de [`app/config.js`](app/config.js), puis **n'est plus
jamais remplacé** : après une mise à jour, les nouvelles options doivent y être ajoutées à la main.
Redémarrer l'add-on pour appliquer.

| Clé | Rôle |
|---|---|
| `dockApps` | Apps épinglées dans le dock, dans l'ordre |
| `hiddenApps` | Apps jamais affichées |
| `inputTiles` | Entrées HDMI affichées en tuiles : titre, icône (`pc`, `console`, `hdmi` ou une image posée à côté de `config.js`), couleur |
| `liveTvApp` | App TV en direct proposée dans le menu Sources (vide pour l'omettre) |
| `columns` | Tuiles par ligne ; le dock a autant de places (ex. `6` pour 6 apps dans le dock) |

Les ids d'apps sont listés dans le log de l'add-on à chaque démarrage. Modifier `dockApps`
réinitialise l'ordre arrangé sur la TV.

**Réorganiser sur la TV** : maintenir **OK** sur une tuile jusqu'à ce qu'elle bouge, la déplacer avec
les flèches (la ligne du haut est le dock), **OK** pour la poser, **Retour** pour annuler.

## Nettoyer l'accueil LG

Pour les moments où on tombe dessus (les noms varient selon la version de webOS) :

- **Paramètres → Général → Système → Paramètres supplémentaires → Paramètres d'accueil** : désactiver
  la promotion et les recommandations de contenu.
- **Paramètres → Support → Confidentialité et conditions → Accords utilisateur** : décocher les
  informations de visionnage et les recommandations basées sur les centres d'intérêt.

## Dépannage

- **« Could not fetch the SSH key »** : activer **Key Server** dans l'app Developer Mode, redémarrer
  l'add-on.
- **« 403 Pairing rejected: blacklisted certificate detected »** : les firmwares récents rejettent le
  manifeste signé partagé par les clients open source ; `lgtv.py` s'appaire avec un manifeste non
  signé, qui passe.
- **Pas de demande d'appairage sur la TV** : activer la connexion depuis les apps mobiles
  (Paramètres → Général → Appareils → Appareils externes, « LG Connect Apps » ou similaire).
- **Les apps ne s'ouvrent plus** : la session Developer Mode a expiré. **Extend Session Time** dans
  l'app Developer Mode, puis vérifier que la TV est joignable la nuit (veille réseau).
- **Mes changements n'apparaissent pas après une mise à jour** : vérifier dans le log que
  l'installation a réussi, et que les nouvelles options sont bien dans le `config.js` de
  `/addon_configs` (il n'est pas mis à jour automatiquement).

## Fichiers

| Fichier | Rôle |
|---|---|
| [`app/`](app/) | Le launcher (web app webOS) |
| [`run.sh`](run.sh) | Point d'entrée de l'add-on : clé SSH, installation, prolongation Developer Mode, watcher |
| [`install.sh`](install.sh) | Synchronise les apps, empaquette et installe le launcher |
| [`sync-apps.py`](sync-apps.py) | Lit apps, icônes et entrées HDMI de la TV vers `app/apps.js` et `app/icons/` |
| [`home-watch.py`](home-watch.py) | Renvoie le bouton Home vers le launcher |
| [`lgtv.py`](lgtv.py) | Appairage et dialogue avec le service de télécommande de la TV |
| [`config.yaml`](config.yaml), [`Dockerfile`](Dockerfile), [`repository.yaml`](repository.yaml) | Manifeste et image de l'add-on |

## Crédits

Fork de [webos-vibehack](https://github.com/OmkarK97/webos-vibehack), portage webOS de
[tv-vibehack](https://github.com/Gathin23/tv-vibehack) par [Gathin](https://github.com/Gathin23)
(design, mise en page, icône). Police Outfit sous SIL Open Font License
([`app/fonts/OFL.txt`](app/fonts/OFL.txt)). Licence MIT, voir [`LICENSE`](LICENSE).
