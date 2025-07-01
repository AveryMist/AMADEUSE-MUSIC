# 🆘 Support et Aide - AMADEUSE MUSIC

## 💬 **Communauté et Support**

### **🎮 Discord Officiel**
Rejoignez notre communauté Discord pour :
- 💬 **Discussions** en temps réel avec d'autres utilisateurs
- 🆘 **Support technique** rapide et personnalisé
- 📢 **Annonces** des nouvelles versions et fonctionnalités
- 💡 **Suggestions** et retours pour améliorer l'app
- 🎉 **Événements** communautaires et concours
- 🎵 **Partage** de playlists et découvertes musicales

**🔗 [Rejoindre le Discord AMADEUSE MUSIC](https://discord.gg/GEZCQwczMY)**

---

## 🔧 **Résolution de Problèmes**

### **❌ Problèmes d'Installation**

#### **📱 Android - "Installation bloquée"**
- ✅ Vérifiez que "Sources inconnues" est activé
- ✅ Redémarrez votre appareil Android
- ✅ Libérez au moins 200MB d'espace de stockage
- ✅ Désactivez temporairement l'antivirus
- ✅ Essayez avec un gestionnaire de fichiers différent

#### **📱 Android - "Application non installée"**
- ✅ Désinstallez toute version précédente
- ✅ Téléchargez à nouveau l'APK (fichier peut être corrompu)
- ✅ Vérifiez la compatibilité Android (5.0+ requis)
- ✅ Vérifiez l'intégrité avec le checksum SHA256

#### **💻 Windows - "Windows a protégé votre PC"**
- ✅ Cliquez sur "Plus d'infos" puis "Exécuter quand même"
- ✅ Ajoutez une exception dans Windows Defender
- ✅ Lancez en tant qu'administrateur si nécessaire
- ✅ Vérifiez que tous les fichiers DLL sont présents

#### **🐧 Linux - "Permission denied"**
- ✅ Donnez les permissions d'exécution : `chmod +x amadeuse_music`
- ✅ Vérifiez les dépendances système requises
- ✅ Installez les bibliothèques manquantes
- ✅ Utilisez `sudo` si nécessaire

---

### **📱 Problèmes d'Utilisation**

#### **L'application ne démarre pas**
- 🔄 Redémarrez votre appareil
- 🧹 Videz le cache de l'application
- 📱 Vérifiez la RAM disponible (minimum 2GB Android, 4GB PC)
- 🔋 Assurez-vous d'avoir au moins 20% de batterie (mobile)
- 🌐 Vérifiez votre connexion internet

#### **Problèmes de streaming YouTube**
- 🌐 Vérifiez votre connexion internet
- 🔄 Redémarrez l'application
- 📱 Videz le cache de l'app
- ⚙️ Changez la qualité de streaming dans les paramètres
- 🕐 Attendez quelques minutes (limitation temporaire possible)

#### **Audio ne fonctionne pas**
- 🔊 Vérifiez le volume système et de l'app
- 🎧 Testez avec et sans écouteurs/casque
- 🔄 Redémarrez l'application
- ⚙️ Vérifiez les paramètres audio dans l'app
- 📱 Accordez les permissions audio si demandées

#### **Téléchargements échouent**
- 📶 Vérifiez votre connexion internet stable
- 💾 Libérez de l'espace de stockage
- ⚙️ Vérifiez les permissions de stockage
- 🔄 Réessayez le téléchargement
- 📱 Redémarrez l'app si le problème persiste

---

### **🎵 Problèmes Audio Spécifiques**

#### **Égaliseur ne fonctionne pas**
- 📱 **Android** : Vérifiez que l'égaliseur système n'interfère pas
- 💻 **Windows** : Redémarrez l'app après changement de paramètres
- ⚙️ Réinitialisez les paramètres d'égaliseur
- 🔄 Testez avec différentes pistes audio

#### **Paroles ne s'affichent pas**
- 🌐 Vérifiez votre connexion internet (paroles en ligne)
- ⚙️ Activez l'affichage des paroles dans les paramètres
- 🔄 Changez de piste et revenez
- 📱 Certaines pistes peuvent ne pas avoir de paroles disponibles

#### **Skip silence ne fonctionne pas**
- ⚙️ Vérifiez que la fonction est activée dans les paramètres
- 🎵 Testez avec différents types de pistes
- 🔄 Redémarrez la lecture
- 📱 Fonction peut ne pas marcher sur toutes les pistes

---

### **🔄 Problèmes de Synchronisation**

#### **Synchronisation entre appareils ne fonctionne pas**
- 🌐 Vérifiez que tous les appareils sont sur le même réseau WiFi
- ⚙️ Activez la synchronisation dans les paramètres
- 🔄 Redémarrez l'app sur tous les appareils
- 📱 Vérifiez les permissions réseau
- 🕐 Attendez quelques minutes pour la détection automatique

#### **Playlists ne se synchronisent pas**
- ⚙️ Vérifiez les paramètres de synchronisation des playlists
- 🔄 Forcez une synchronisation manuelle
- 📱 Vérifiez l'espace de stockage disponible
- 🌐 Assurez-vous d'une connexion stable

---

## 📋 **Informations de Diagnostic**

### **Informations à Fournir pour le Support**

Quand vous demandez de l'aide, incluez ces informations :

#### **📱 Android**
- Version Android (ex: Android 12)
- Modèle d'appareil (ex: Samsung Galaxy S21)
- Version d'AMADEUSE MUSIC (ex: 1.12.0)
- RAM disponible
- Espace de stockage libre
- Message d'erreur exact (capture d'écran)

#### **💻 Windows**
- Version Windows (ex: Windows 11 22H2)
- Architecture (x64/x86)
- RAM installée
- Version d'AMADEUSE MUSIC
- Message d'erreur exact
- Logs d'erreur si disponibles

#### **🐧 Linux**
- Distribution (ex: Ubuntu 22.04)
- Version du kernel
- Environnement de bureau (GNOME, KDE, etc.)
- Bibliothèques installées
- Messages d'erreur terminal

---

## 🛠️ **Outils de Diagnostic**

### **📱 Android - Logs de Debug**
```bash
# Via ADB (pour développeurs)
adb logcat | grep "AMADEUSE"

# Informations système
adb shell getprop ro.build.version.release
adb shell df /data
```

### **💻 Windows - Informations Système**
```powershell
# Informations système
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, TotalPhysicalMemory

# Vérification des DLL
Get-ChildItem "Amadeuse_Music_Windows\*.dll"
```

### **🐧 Linux - Diagnostic**
```bash
# Informations système
uname -a
lsb_release -a

# Bibliothèques disponibles
ldd amadeuse_music

# Permissions
ls -la amadeuse_music
```

---

## 📞 **Canaux de Support**

### **🎯 Support Prioritaire**
1. **Discord** - Réponse rapide, communauté active
2. **GitHub Issues** - Pour les bugs et demandes de fonctionnalités
3. **Email** - Pour les questions complexes

### **📧 Contact Email**
- **Support général** : support@amadeuse-music.dev
- **Bugs critiques** : bugs@amadeuse-music.dev
- **Suggestions** : feedback@amadeuse-music.dev

### **🐛 GitHub Issues**
**🔗 [Créer un Issue](https://github.com/AveryMist/AMADEUSE-MUSIC/issues)**

**Types d'issues :**
- 🐛 **Bug Report** - Problèmes et dysfonctionnements
- ✨ **Feature Request** - Nouvelles fonctionnalités
- 📖 **Documentation** - Améliorations de la doc
- ❓ **Question** - Questions générales

---

## 🎓 **Ressources d'Apprentissage**

### **📚 Documentation**
- **README.md** - Vue d'ensemble et installation
- **FEATURES.md** - Fonctionnalités détaillées
- **INSTALLATION.md** - Guide d'installation complet
- **CHANGELOG.md** - Historique des versions

### **🎥 Tutoriels Vidéo** (À venir)
- Installation et premier lancement
- Configuration des paramètres
- Utilisation avancée des fonctionnalités
- Synchronisation multi-appareils

### **📝 Guides Communautaires**
- Optimisation des performances
- Personnalisation avancée
- Résolution de problèmes courants
- Astuces et conseils d'utilisation

---

## 🤝 **Contribuer au Support**

### **Aider la Communauté**
- Répondez aux questions sur Discord
- Partagez vos solutions aux problèmes
- Créez des guides et tutoriels
- Testez les nouvelles versions

### **Améliorer la Documentation**
- Signalez les erreurs dans la documentation
- Proposez des améliorations
- Traduisez dans d'autres langues
- Créez des FAQ

### **Développement**
- Contribuez au code source
- Testez et signalez les bugs
- Proposez de nouvelles fonctionnalités
- Aidez avec les traductions

---

## 🏆 **Remerciements**

Merci à tous ceux qui contribuent au support d'AMADEUSE MUSIC :
- 👥 **Communauté Discord** - Support mutuel et tests
- 🧪 **Beta testeurs** - Tests des nouvelles fonctionnalités
- 🌍 **Traducteurs** - Support multi-langues
- 💻 **Contributeurs** - Améliorations du code
- 📝 **Rédacteurs** - Documentation et guides
