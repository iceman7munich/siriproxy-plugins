Plugins pour siriproxy en français
==================================

Licence
-------
Mes plugins sont distribués sous licence [Creative Commons Attribution-NonCommercial-ShareAlike 3.0](http://creativecommons.org/licenses/by-nc-sa/3.0/deed.fr). Ce qui signifie, en quelques mots, que vous pouvez utiliser ces plugins comme nous l'entendez, sauf pour un usage commercial (vous ne pouvez pas utilisez mes plugins sur un serveur où l'accès est payant). Si vous modifiez le code d'un plugin, vous êtes également tenu de redistribuer vos modifications sous la même licence.

Pour un usage qui n'est pas inclus dans cette licence ou pour de l'aide concernant l'installation ou la personnalisation d'un plugin, vous pouvez [me contacter](http://blog.boverie.eu/contact/).

La licence commerciale inclus également un plugin pour poster des messages sur Twitter et Facebook compatibles avec les serveurs publiques (multi-utilisateurs).

Notice d'installation
---------------------

### Récupérer les sources
* Option 1 : [Télécharger manuellement l'ensemble des plugins](https://github.com/cedbv/siriproxy-plugins/zipball/master)
* Option 2 : Cloner le dépôt avec git

``` git clone git://github.com/cedbv/siriproxy-plugins.git ``` 

### Installation d'un plugin
(à faire pour chaque plugin à installer)

1) Enregistrer le plugin dans le fichier ~/.siriproxy/config.yml en rajoutant le bloc suivant **dans la section plugins** :

    - name: 'NomDuPlugin'
      path: '/chemin-complet-vers-le-repertoire-contenant-les-plugins/siriproxy-nomduplugin'

2) Mettre à jour le serveur

    siriproxy update .

3) Démarrer/redémarrer le serveur

Remerciements
--------------
Merci à tous ceux qui ont participé au développement de [SiriProxy](https://github.com/plamoni/SiriProxy).