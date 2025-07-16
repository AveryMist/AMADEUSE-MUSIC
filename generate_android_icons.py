#!/usr/bin/env python3
"""
Script pour générer les icônes Android AMADEUSE MUSIC
"""

import os
import sys
from PIL import Image, ImageDraw

def create_amadeuse_icon(size, output_path):
    """Crée une icône AMADEUSE MUSIC avec des barres d'égaliseur"""
    
    # Couleurs du thème AMADEUSE (cohérence avec AMADEUSE read)
    bg_color1 = "#5c64f4"  # Bleu AMADEUSE rgb(92,100,244)
    bg_color2 = "#4752c4"  # Bleu plus foncé pour le dégradé
    bar_color = "#ffffff"  # Barres blanches
    
    # Créer une nouvelle image avec fond transparent
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Dessiner le fond circulaire avec dégradé simulé
    margin = size // 20
    circle_size = size - 2 * margin
    
    # Simuler un dégradé en dessinant plusieurs cercles
    for i in range(circle_size // 2):
        # Interpolation entre les deux couleurs
        ratio = i / (circle_size // 2)
        r1, g1, b1 = int(bg_color1[1:3], 16), int(bg_color1[3:5], 16), int(bg_color1[5:7], 16)
        r2, g2, b2 = int(bg_color2[1:3], 16), int(bg_color2[3:5], 16), int(bg_color2[5:7], 16)
        
        r = int(r1 + (r2 - r1) * ratio)
        g = int(g1 + (g2 - g1) * ratio)
        b = int(b1 + (b2 - b1) * ratio)
        
        current_radius = circle_size // 2 - i
        if current_radius > 0:
            draw.ellipse([
                margin + i, margin + i,
                size - margin - i, size - margin - i
            ], fill=(r, g, b, 255))
    
    # Dessiner les barres d'égaliseur
    center_x = size // 2
    center_y = size // 2
    
    # Calculer les dimensions des barres
    bar_width = max(2, size // 25)
    max_bar_height = size // 3
    spacing = max(3, size // 20)
    
    # Hauteurs des barres (pattern d'égaliseur)
    bar_heights = [0.4, 0.7, 0.9, 1.0, 0.8, 0.6, 0.3]
    total_width = len(bar_heights) * bar_width + (len(bar_heights) - 1) * spacing
    start_x = center_x - total_width // 2
    
    for i, height_ratio in enumerate(bar_heights):
        bar_height = int(max_bar_height * height_ratio)
        x = start_x + i * (bar_width + spacing)
        y = center_y - bar_height // 2
        
        # Dessiner la barre avec coins arrondis
        corner_radius = min(bar_width // 4, 3)
        draw.rounded_rectangle([x, y, x + bar_width, y + bar_height], 
                             radius=corner_radius, fill=bar_color)
    
    # Sauvegarder l'image
    img.save(output_path, 'PNG')
    return True

def create_background_icon(size, output_path):
    """Crée l'icône de fond pour Android (adaptive icon)"""
    
    # Couleurs du thème AMADEUSE (cohérence avec AMADEUSE read)
    bg_color1 = "#5c64f4"  # Bleu AMADEUSE rgb(92,100,244)
    bg_color2 = "#4752c4"  # Bleu plus foncé pour le dégradé
    
    # Créer une nouvelle image
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Dessiner le fond circulaire avec dégradé simulé
    for i in range(size // 2):
        # Interpolation entre les deux couleurs
        ratio = i / (size // 2)
        r1, g1, b1 = int(bg_color1[1:3], 16), int(bg_color1[3:5], 16), int(bg_color1[5:7], 16)
        r2, g2, b2 = int(bg_color2[1:3], 16), int(bg_color2[3:5], 16), int(bg_color2[5:7], 16)
        
        r = int(r1 + (r2 - r1) * ratio)
        g = int(g1 + (g2 - g1) * ratio)
        b = int(b1 + (b2 - b1) * ratio)
        
        current_radius = size // 2 - i
        if current_radius > 0:
            draw.ellipse([
                i, i, size - i, size - i
            ], fill=(r, g, b, 255))
    
    # Sauvegarder l'image
    img.save(output_path, 'PNG')
    return True

def create_foreground_icon(size, output_path):
    """Crée l'icône de premier plan pour Android (adaptive icon)"""
    
    # Créer une nouvelle image avec fond transparent
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Dessiner les barres d'égaliseur
    center_x = size // 2
    center_y = size // 2
    
    # Calculer les dimensions des barres (plus grandes pour le foreground)
    bar_width = max(3, size // 20)
    max_bar_height = size // 2.5
    spacing = max(4, size // 15)
    
    # Hauteurs des barres (pattern d'égaliseur)
    bar_heights = [0.4, 0.7, 0.9, 1.0, 0.8, 0.6, 0.3]
    total_width = len(bar_heights) * bar_width + (len(bar_heights) - 1) * spacing
    start_x = center_x - total_width // 2
    
    for i, height_ratio in enumerate(bar_heights):
        bar_height = int(max_bar_height * height_ratio)
        x = start_x + i * (bar_width + spacing)
        y = center_y - bar_height // 2
        
        # Dessiner la barre avec coins arrondis
        corner_radius = min(bar_width // 3, 5)
        draw.rounded_rectangle([x, y, x + bar_width, y + bar_height], 
                             radius=corner_radius, fill="#ffffff")
    
    # Sauvegarder l'image
    img.save(output_path, 'PNG')
    return True

def create_monochrome_icon(size, output_path):
    """Crée l'icône monochrome pour Android basée sur amadeuse_music.png"""

    try:
        # Charger le logo original amadeuse_music.png
        original_logo = Image.open("amadeuse_music.png")

        # Redimensionner le logo à la taille demandée
        logo_resized = original_logo.resize((size, size), Image.Resampling.LANCZOS)

        # Créer une nouvelle image monochrome
        img = Image.new('RGBA', (size, size), (0, 0, 0, 0))

        # Convertir en monochrome (blanc sur transparent)
        logo_gray = logo_resized.convert('L')  # Convertir en niveaux de gris
        logo_array = list(logo_gray.getdata())

        # Créer l'image monochrome
        for y in range(size):
            for x in range(size):
                pixel_index = y * size + x
                if pixel_index < len(logo_array):
                    # Si le pixel n'est pas transparent dans l'original
                    original_pixel = original_logo.resize((size, size), Image.Resampling.LANCZOS).getpixel((x, y))
                    if len(original_pixel) > 3 and original_pixel[3] > 128:  # Alpha > 128
                        img.putpixel((x, y), (255, 255, 255, 255))  # Blanc opaque
                    else:
                        img.putpixel((x, y), (0, 0, 0, 0))  # Transparent

        # Sauvegarder l'image
        img.save(output_path, 'PNG')
        return True

    except Exception as e:
        print(f"Erreur lors de la création de l'icône monochrome: {e}")
        # Fallback vers l'ancienne méthode si le logo original n'est pas trouvé
        return create_monochrome_icon_fallback(size, output_path)

def create_monochrome_icon_fallback(size, output_path):
    """Méthode de fallback pour créer l'icône monochrome"""

    # Créer une nouvelle image avec fond transparent
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Dessiner les barres d'égaliseur en blanc
    center_x = size // 2
    center_y = size // 2

    # Calculer les dimensions des barres
    bar_width = max(3, size // 20)
    max_bar_height = size // 2.5
    spacing = max(4, size // 15)

    # Hauteurs des barres (pattern d'égaliseur)
    bar_heights = [0.4, 0.7, 0.9, 1.0, 0.8, 0.6, 0.3]
    total_width = len(bar_heights) * bar_width + (len(bar_heights) - 1) * spacing
    start_x = center_x - total_width // 2

    for i, height_ratio in enumerate(bar_heights):
        bar_height = int(max_bar_height * height_ratio)
        x = start_x + i * (bar_width + spacing)
        y = center_y - bar_height // 2

        # Dessiner la barre avec coins arrondis
        corner_radius = min(bar_width // 3, 5)
        draw.rounded_rectangle([x, y, x + bar_width, y + bar_height],
                             radius=corner_radius, fill="#ffffff")

    # Sauvegarder l'image
    img.save(output_path, 'PNG')
    return True

def create_adaptive_icon_xml():
    """Crée les fichiers XML pour les icônes adaptatives Android"""

    # Créer le dossier mipmap-anydpi-v26 s'il n'existe pas
    anydpi_folder = "android/app/src/main/res/mipmap-anydpi-v26"
    os.makedirs(anydpi_folder, exist_ok=True)

    # Contenu XML pour l'icône adaptive
    ic_launcher_xml = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
    <monochrome android:drawable="@mipmap/ic_launcher_monochrome" />
</adaptive-icon>'''

    # Écrire le fichier ic_launcher.xml
    with open(f"{anydpi_folder}/ic_launcher.xml", 'w', encoding='utf-8') as f:
        f.write(ic_launcher_xml)

    return True

def main():
    """Génère toutes les icônes Android nécessaires à partir d'amadeuse_music.png"""

    try:
        from PIL import Image
        print("✓ PIL/Pillow trouvé")
    except ImportError:
        print("❌ PIL/Pillow n'est pas installé. Utilisez: pip install Pillow")
        return

    # Vérifier que le logo original existe
    if not os.path.exists("amadeuse_music.png"):
        print("❌ Le fichier amadeuse_music.png n'existe pas dans le dossier racine!")
        return

    print("🤖 Génération des icônes Android à partir d'amadeuse_music.png...")

    # Charger le logo original
    try:
        original_logo = Image.open("amadeuse_music.png")
        print(f"✓ Logo original chargé: {original_logo.size}")
    except Exception as e:
        print(f"❌ Erreur lors du chargement du logo: {e}")
        return

    # Tailles Android
    android_sizes = {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192
    }

    success_count = 0
    total_count = 0

    for density, size in android_sizes.items():
        folder = f"android/app/src/main/res/mipmap-{density}"
        os.makedirs(folder, exist_ok=True)

        # Icône principale - juste redimensionner amadeuse_music.png
        total_count += 1
        try:
            resized_logo = original_logo.resize((size, size), Image.Resampling.LANCZOS)
            resized_logo.save(f"{folder}/ic_launcher.png", 'PNG')
            print(f"✓ Généré: {folder}/ic_launcher.png")
            success_count += 1
        except Exception as e:
            print(f"❌ Erreur: {e}")

        # Icône monochrome - version monochrome d'amadeuse_music.png
        total_count += 1
        try:
            # Créer version monochrome
            resized_logo = original_logo.resize((size, size), Image.Resampling.LANCZOS)
            # Convertir en monochrome blanc sur transparent
            mono_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))

            for y in range(size):
                for x in range(size):
                    pixel = resized_logo.getpixel((x, y))
                    # Si le pixel n'est pas transparent
                    if len(pixel) > 3 and pixel[3] > 128:  # Alpha > 128
                        mono_img.putpixel((x, y), (255, 255, 255, 255))  # Blanc opaque
                    else:
                        mono_img.putpixel((x, y), (0, 0, 0, 0))  # Transparent

            mono_img.save(f"{folder}/ic_launcher_monochrome.png", 'PNG')
            print(f"✓ Généré: {folder}/ic_launcher_monochrome.png")
            success_count += 1
        except Exception as e:
            print(f"❌ Erreur: {e}")

    print(f"\n🎉 Génération terminée: {success_count}/{total_count} icônes Android générées avec succès!")

    if success_count < total_count:
        print("\n⚠️  Certaines icônes n'ont pas pu être générées.")
    else:
        print("\n✨ Toutes les icônes Android ont été générées avec succès!")
        print("🎵 Utilisation directe du logo amadeuse_music.png")
        print("📱 Icônes monochrome générées pour les notifications")

if __name__ == "__main__":
    main()
