Readme chatbot v 1.0



Pour lancer le chatbot, utiliser la ligne de commande suivante :
./dark chatbot.lua

Pour lancer le chatbot en utilisant des bases de données pré-extraites, décommenter l'une des lignes 22 ou 23 du fichier chatbot.lua, et commenter la ligne 21.

___________



Les questions que nous pouvons poser au bot sont des questions simples, contenant un type d'information et/ou une race de chien.

Avec la base de donnée réelle, il n'est pas encore possible de poser des questions sur le poids.

-----------

Voici des exemples de questions :

Bonjour, peux-tu me parler du beagle ?

Quelle est sa taille ? 

Quelle est celle du golden retriever ?

Qu'en est-il du beagle ?

Peux-tu me parler du golden retriever ?

Quelle est sont utilité ?

D'où vient-il ?

Et le beagle ?



-----------


Voici un exemple de dialogue avec les questions ci-dessus, dans l'ordre (la base de donnée entrée à la main reste assez limitée).
Le texte a été directement copié depuis la console :


Bot : Bonjour je suis un chatbot :) Je peux parler du Beagle ou du Golden retriever.

Bonjour, peux tu me parler du beagle ?

Infochien : Nous parlons bien du beagle là, n'est-ce pas ?

Quelle est sa taille ?

Infochien : la taille du beagle est 19 cm.
Infochien : voulez-vous d'autres informations sur les chiens ?

Quelle est celle du golden retriever ?

Infochien : la taille du golden retriever est taille moyenne.
Infochien : voulez-vous d'autres informations sur les chiens ?

Qu'en est-il du beagle ?

Infochien : la taille du beagle est 19 cm.
Infochien : voulez-vous d'autres informations sur les chiens ?

Peux-tu me parler du golden retriever maintenant ?

Infochien : la taille du golden retriever est taille moyenne.
Infochien : quelque chose d'autre ?

Quelle est son utilité ?

Infochien : l'utilisation du golden retriever est chien de police, chien de compagnie, chien de bail, chien de montagne et chien de campagne.
Infochien : ouaf.

D'où vient-il ?

Infochien : l'origine du golden retriever est : Système Solaire.
Infochien : voulez-vous en savoir plus ?

Et le beagle ?

Infochien : l'origine du beagle est : US of A.
Infochien : d'autres questions ?

----------

Etat actuel de la BD, parsée à partir des textes :


{
  beagle = {
    origin = "angleterre",
    height = "de taille petite",
    use = {
      [1] = "chien de compagnie",
      [2] = "chien de chasse",
      [3] = "chien de détection",
      [4] = "chien de laboratoire",
    },
  },
  ["labrador retriever"] = {
    origin = "royaume - uni",
    height = "de taille moyenne",
    use = {
      [1] = "chien de compagnie",
      [2] = "chien de rapport",
      [3] = "chien d ' assistance",
      [4] = "chien de sauvetage",
      [5] = "chien de détection",
      [6] = "chien policier",
      [7] = "chien truffier",
    },
  },
  ["terre - neuve"] = {
    origin = "île canadienne de terre - neuve",
    height = "forte taille",
    use = {
      [1] = "chien de compagnie",
      [2] = "chien de sauvetage",
    },
  },
}





----------
