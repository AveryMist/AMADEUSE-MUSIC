# 📱💻 Guide d'Installation - AMADEUSE MUSIC

## 🚀 Installation Rapide

### **📱 Android**

#### **Étape 1 : Téléchargement**
1. Téléchargez le fichier `amadeuse_music.apk` depuis ce repository
2. Assurez-vous que le téléchargement est complet (taille ~25MB)

#### **Étape 2 : Préparation Android**
1. Ouvrez **Paramètres** sur votre appareil Android
2. Allez dans **Sécurité** ou **Confidentialité**
3. Activez **Sources inconnues** ou **Installer des applications inconnues**
4. Autorisez votre navigateur ou gestionnaire de fichiers

#### **Étape 3 : Installation**
1. Localisez le fichier `amadeuse_music.apk` dans vos téléchargements
2. Appuyez sur le fichier pour lancer l'installation
3. Confirmez l'installation en appuyant sur **Installer**
4. Attendez la fin de l'installation

#### **Étape 4 : Premier Lancement**
1. Appuyez sur **Ouvrir** ou trouvez l'icône AMADEUSE MUSIC
2. Accordez les permissions demandées (stockage, réseau, audio)
3. Configurez vos préférences initiales
4. Commencez à écouter ! 🎵

---

### **💻 Windows**

#### **Étape 1 : Téléchargement**
1. Téléchargez le dossier `Amadeuse_Music_Windows` depuis ce repository
2. Assurez-vous que tous les fichiers sont présents (taille ~150MB)

#### **Étape 2 : Extraction**
1. Extrayez le dossier `Amadeuse_Music_Windows` où vous le souhaitez
2. Recommandé : `C:\Program Files\Amadeuse_Music_Windows\`
3. Ou sur le Bureau pour un accès facile

#### **Étape 3 : Installation**
1. Ouvrez le dossier extrait
2. Double-cliquez sur `AMADEUSE_MUSIC.exe`
3. Si Windows Defender bloque : cliquez "Plus d'infos" puis "Exécuter quand même"
4. L'application se lance directement (pas d'installation requise)

#### **Étape 4 : Raccourci (Optionnel)**
1. Clic droit sur `AMADEUSE_MUSIC.exe`
2. Sélectionnez "Créer un raccourci"
3. Déplacez le raccourci sur le Bureau ou dans le menu Démarrer

---

### **🐧 Linux**

#### **Prérequis**
- Distribution Linux moderne (Ubuntu 18.04+, Debian 10+, Fedora 30+)
- Architecture x64
- Bibliothèques système à jour

#### **Installation**
```bash
# Téléchargez et extrayez l'archive Linux
wget [lien_vers_archive_linux]
tar -xzf amadeuse_music_linux.tar.gz

# Rendez l'exécutable
chmod +x amadeuse_music

# Lancez l'application
./amadeuse_music
```

---

## 🔧 Installation Avancée

### **📱 Android - Via ADB (Développeurs)**
```bash
# Activez le débogage USB sur votre appareil
adb devices
adb install amadeuse_music.apk

# Installation forcée (remplace version existante)
adb install -r amadeuse_music.apk
```

### **📱 Android - Installation Silencieuse (Root)**
```bash
# Nécessite les droits root
su
pm install amadeuse_music.apk

# Installation système (nécessite root)
adb push amadeuse_music.apk /system/app/
```

### **💻 Windows - Installation Portable**
1. Copiez le dossier `Amadeuse_Music_Windows` sur une clé USB
2. Lancez directement `AMADEUSE_MUSIC.exe` depuis la clé
3. Toutes les données seront stockées sur la clé USB

### **💻 Windows - Variables d'Environnement**
```batch
# Ajout au PATH pour lancement depuis n'importe où
set PATH=%PATH%;C:\Program Files\Amadeuse_Music_Windows\

# Lancement depuis CMD/PowerShell
AMADEUSE_MUSIC.exe
```

---

## ⚠️ Résolution de Problèmes

### **📱 Android - Problèmes Courants**

#### **"Installation bloquée"**
- Vérifiez que "Sources inconnues" est activé
- Essayez d'installer via un gestionnaire de fichiers différent
- Redémarrez l'appareil et réessayez

#### **"Application non installée"**
- Vérifiez l'espace de stockage disponible (minimum 100MB)
- Désinstallez l'ancienne version si présente
- Vérifiez l'intégrité du fichier APK téléchargé

#### **"Erreur d'analyse du package"**
- Re-téléchargez le fichier APK
- Vérifiez que votre Android est version 5.0 minimum
- Essayez l'installation via ADB

#### **Permissions refusées**
- Allez dans Paramètres > Applications > AMADEUSE MUSIC
- Accordez manuellement les permissions nécessaires
- Redémarrez l'application

### **💻 Windows - Problèmes Courants**

#### **"Windows a protégé votre PC"**
- Cliquez sur "Plus d'infos"
- Sélectionnez "Exécuter quand même"
- Ajoutez une exception dans Windows Defender si nécessaire

#### **"Fichier DLL manquant"**
- Vérifiez que tous les fichiers .dll sont présents dans le dossier
- Re-téléchargez le package complet
- Installez Visual C++ Redistributable si demandé

#### **"L'application ne se lance pas"**
- Vérifiez que vous avez Windows 10 ou plus récent
- Lancez en tant qu'administrateur
- Vérifiez les logs dans le dossier de l'application

#### **Performance lente**
- Fermez les autres applications gourmandes
- Vérifiez l'espace disque disponible
- Ajustez les paramètres de qualité dans l'application

### **🐧 Linux - Problèmes Courants**

#### **"Permission denied"**
```bash
# Donnez les permissions d'exécution
chmod +x amadeuse_music

# Si problème persiste, vérifiez le propriétaire
sudo chown $USER:$USER amadeuse_music
```

#### **"Bibliothèques manquantes"**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install libgtk-3-0 libblkid1 liblzma5

# Fedora
sudo dnf install gtk3 util-linux-libs xz-libs

# Arch Linux
sudo pacman -S gtk3 util-linux xz
```

---

## 🔄 Mise à Jour

### **📱 Android**
1. Téléchargez la nouvelle version APK
2. Installez par-dessus l'ancienne version
3. Vos données et paramètres seront conservés

### **💻 Windows**
1. Fermez l'application actuelle
2. Remplacez les fichiers par la nouvelle version
3. Relancez l'application

### **🐧 Linux**
1. Remplacez l'exécutable par la nouvelle version
2. Conservez vos fichiers de configuration
3. Relancez l'application

---

## 📋 Configuration Système Requise

### **📱 Android**
- **Version minimum** : Android 5.0 (API 21)
- **RAM** : 2GB minimum, 4GB recommandé
- **Stockage** : 100MB pour l'app + espace pour la musique
- **Connexion** : WiFi ou données mobiles pour le streaming

### **💻 Windows**
- **Version** : Windows 10 64-bit ou plus récent
- **RAM** : 4GB minimum, 8GB recommandé
- **Stockage** : 200MB pour l'app + espace pour la musique
- **Connexion** : Internet pour le streaming

### **🐧 Linux**
- **Distribution** : Ubuntu 18.04+, Debian 10+, Fedora 30+
- **Architecture** : x86_64
- **RAM** : 4GB minimum, 8GB recommandé
- **Stockage** : 200MB pour l'app + espace pour la musique

---

## 🆘 Support

Si vous rencontrez des problèmes non résolus par ce guide :

1. **Discord** : Rejoignez notre serveur Discord pour une aide en temps réel
2. **GitHub Issues** : Créez un ticket sur le repository GitHub
3. **Email** : Contactez le support technique

**Informations à fournir pour le support :**
- Version du système d'exploitation
- Version d'AMADEUSE MUSIC
- Description détaillée du problème
- Étapes pour reproduire le problème
- Captures d'écran si applicable
