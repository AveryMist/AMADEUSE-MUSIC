# 🔐 Vérification d'Intégrité - AMADEUSE MUSIC

## 📱 **Fichier APK : amadeuse_music.apk**

### **Informations du Fichier**
- **Nom** : amadeuse_music.apk
- **Version** : Alpha 0.1
- **Taille** : ~31 MB (32,287,543 bytes)
- **Date de compilation** : Juillet 2025

### **🔍 Checksums de Vérification**

#### **SHA256**
```
014FD6FE2A39F8968CB3897B7B0B6A939F5811EDFE5FFF4CA69F6F9738BC3D0B
```

#### **MD5** 
```
(En cours de calcul - utilisez SHA256 pour vérification principale)
```

---

## 💻 **Fichier Windows : Amadeuse_Music_Windows/**

### **Informations du Package**
- **Nom** : Amadeuse_Music_Windows
- **Version** : Alpha 0.1
- **Taille** : ~150 MB (avec toutes les dépendances)
- **Date de compilation** : Juillet 2025

### **🔍 Fichiers Principaux**

#### **AMADEUSE_MUSIC.exe**
```
SHA256: 6B3700DFE575B7C8572273210CBF6AC3867FFC2EF965C4379F68882E5D9EDB53
Taille: ~25 MB
```

#### **Dépendances DLL**
- `flutter_windows.dll` - Runtime Flutter pour Windows
- `libmpv-2.dll` - Bibliothèque de lecture multimédia
- `audiotags.dll` - Gestion des métadonnées audio
- `dartjni.dll` - Interface Java Native
- Et autres dépendances système

---

## 🛡️ **Comment Vérifier l'Intégrité**

### **Sur Windows**
```powershell
# Vérification SHA256
Get-FileHash "amadeuse_music.apk" -Algorithm SHA256

# Le résultat doit correspondre exactement au hash ci-dessus
```

### **Sur Linux/Mac**
```bash
# Vérification SHA256
sha256sum amadeuse_music.apk

# Vérification MD5 (optionnel)
md5sum amadeuse_music.apk
```

### **Sur Android (via Terminal)**
```bash
# Si vous avez accès à un terminal Android
sha256sum /sdcard/Download/amadeuse_music.apk
```

---

## 🔒 **Informations de Sécurité**

### **Signature APK**
- **Algorithme** : SHA256withRSA
- **Certificat** : Auto-signé pour distribution directe
- **Validité** : 25 ans (standard Android)
- **Empreinte** : (Disponible via `keytool` après installation)

### **Permissions APK**
- `INTERNET` : Accès aux services de streaming en ligne
- `WRITE_EXTERNAL_STORAGE` : Téléchargements et cache musical
- `READ_EXTERNAL_STORAGE` : Lecture des fichiers musicaux téléchargés
- `WAKE_LOCK` : Maintien de l'écran allumé pendant la lecture
- `VIBRATE` : Retour haptique pour les gestes
- `FOREGROUND_SERVICE` : Lecture en arrière-plan
- `MODIFY_AUDIO_SETTINGS` : Contrôle de l'égaliseur
- `ACCESS_NETWORK_STATE` : Vérification de la connectivité

### **Compatibilité**
- **Android minimum** : 5.0 (API 21)
- **Android cible** : 14 (API 34)
- **Architectures** : ARM64, ARM32, x86_64
- **Densités d'écran** : Toutes supportées

---

## 🖥️ **Informations Windows**

### **Configuration Système**
- **OS minimum** : Windows 10 64-bit
- **RAM** : 4GB minimum, 8GB recommandé
- **Stockage** : 200MB pour l'app + espace pour cache musical
- **Réseau** : Connexion Internet pour streaming

### **Dépendances Incluses**
- **Visual C++ Runtime** : Inclus dans le package
- **Media Foundation** : Utilise les codecs Windows natifs
- **DirectSound** : Pour la sortie audio
- **WinHTTP** : Pour les connexions réseau

### **Sécurité Windows**
- **Code Signing** : Non signé (peut déclencher SmartScreen)
- **Antivirus** : Peut être détecté comme "inconnu" - normal pour les apps non distribuées via Store
- **Firewall** : Peut demander autorisation pour accès réseau

---

## 🔄 **Historique des Versions**

### **Version 1.12.0**
- **SHA256 APK** : `2cf87680999d400ba6f339ae1e93d34344abd723e043dd1f15cc82494eba5922`
- **Date** : Juillet 2025
- **Statut** : Version stable actuelle
- **Taille APK** : 31 MB
- **Taille Windows** : 150 MB

### **Version 1.11.2**
- **SHA256 APK** : `(Archive)`
- **Date** : Juin 2025
- **Statut** : Version précédente
- **Changements** : Corrections de rendu Android

### **Version 1.11.1**
- **SHA256 APK** : `(Archive)`
- **Date** : Mai 2025
- **Statut** : Version précédente
- **Changements** : Améliorations interface et corrections bugs

---

## ⚠️ **Avertissements de Sécurité**

### **Sources de Téléchargement**
- ✅ **Officiel** : Ce repository GitHub
- ❌ **Non officiel** : Sites tiers, stores alternatifs
- ❌ **Modifié** : APK repackagés ou modifiés

### **Vérifications Recommandées**
1. **Toujours vérifier** le checksum SHA256
2. **Télécharger uniquement** depuis les sources officielles
3. **Scanner** avec votre antivirus avant installation
4. **Vérifier** les permissions demandées lors de l'installation

### **Signalement de Problèmes**
Si vous détectez une différence de checksum ou un comportement suspect :
1. **Ne pas installer** le fichier
2. **Signaler** sur notre Discord ou GitHub Issues
3. **Re-télécharger** depuis la source officielle
4. **Vérifier** votre connexion réseau

---

## 🔍 **Outils de Vérification Avancés**

### **Analyse APK Détaillée**
```bash
# Utilisation d'aapt (Android Asset Packaging Tool)
aapt dump badging amadeuse_music.apk

# Analyse avec apktool
apktool d amadeuse_music.apk

# Vérification des certificats
jarsigner -verify -verbose -certs amadeuse_music.apk
```

### **Analyse Antivirus**
- **VirusTotal** : Scan en ligne multi-antivirus
- **Windows Defender** : Scan local Windows
- **Malwarebytes** : Scan approfondi recommandé
- **Avast/AVG** : Détection comportementale

### **Monitoring Réseau**
- **Wireshark** : Analyse du trafic réseau
- **Fiddler** : Proxy pour HTTPS
- **NetLimiter** : Monitoring bande passante

---

## 📞 **Contact Sécurité**

Pour les questions de sécurité ou signalement de vulnérabilités :
- **Email sécurité** : security@amadeuse-music.dev
- **Discord** : Canal #security
- **GitHub** : Issues avec tag "security"

**Divulgation responsable** : Nous encourageons la divulgation responsable des vulnérabilités de sécurité.
