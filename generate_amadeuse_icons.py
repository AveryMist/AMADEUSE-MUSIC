#!/usr/bin/env python3
"""
Script pour générer les icônes AMADEUSE MUSIC avec PIL/Pillow
"""

import os
import sys
from PIL import Image, ImageDraw, ImageFont

def create_amadeuse_icon(size, output_path):
    """Crée une icône AMADEUSE MUSIC avec des barres d'égaliseur"""

    # Couleurs du thème AMADEUSE (cohérence avec AMADEUSE READ)
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

def generate_ico_file(png_path, ico_path):
    """Génère un fichier ICO à partir d'un PNG (Windows)"""
    try:
        from PIL import Image
        img = Image.open(png_path)
        img.save(ico_path, format='ICO', sizes=[(256, 256), (128, 128), (64, 64), (32, 32), (16, 16)])
        print(f"✓ Généré: {ico_path}")
        return True
    except ImportError:
        print("❌ PIL/Pillow n'est pas installé. Utilisez: pip install Pillow")
        return False
    except Exception as e:
        print(f"❌ Erreur lors de la génération de {ico_path}: {e}")
        return False

def main():
    """Génère toutes les icônes nécessaires"""

    try:
        from PIL import Image, ImageDraw
        print("✓ PIL/Pillow trouvé")
    except ImportError:
        print("❌ PIL/Pillow n'est pas installé. Utilisez: pip install Pillow")
        return

    # Créer les dossiers nécessaires
    os.makedirs("assets/icons", exist_ok=True)
    os.makedirs("windows/runner/resources", exist_ok=True)
    os.makedirs("web/icons", exist_ok=True)

    print("🎵 Génération des icônes AMADEUSE MUSIC...")

    # Icônes principales
    sizes = [16, 32, 48, 64, 128, 192, 256, 512, 1024]

    success_count = 0
    total_count = 0

    # Générer les icônes de base
    for size in sizes:
        total_count += 1
        try:
            create_amadeuse_icon(size, f"assets/icons/amadeuse_music_{size}.png")
            print(f"✓ Généré: assets/icons/amadeuse_music_{size}.png")
            success_count += 1
        except Exception as e:
            print(f"❌ Erreur: {e}")

    # Icône principale
    total_count += 1
    try:
        create_amadeuse_icon(512, "assets/icons/icon.png")
        print("✓ Généré: assets/icons/icon.png")
        success_count += 1
    except Exception as e:
        print(f"❌ Erreur: {e}")

    # Icônes Windows
    total_count += 1
    try:
        create_amadeuse_icon(256, "windows/runner/resources/app_icon.png")
        print("✓ Généré: windows/runner/resources/app_icon.png")
        success_count += 1

        # Générer le fichier ICO
        total_count += 1
        if generate_ico_file("windows/runner/resources/app_icon.png", "windows/runner/resources/app_icon.ico"):
            success_count += 1
    except Exception as e:
        print(f"❌ Erreur: {e}")

    # Icônes Web
    web_sizes = [192, 512]
    for size in web_sizes:
        total_count += 1
        try:
            create_amadeuse_icon(size, f"web/icons/Icon-{size}.png")
            print(f"✓ Généré: web/icons/Icon-{size}.png")
            success_count += 1
        except Exception as e:
            print(f"❌ Erreur: {e}")

        total_count += 1
        try:
            create_amadeuse_icon(size, f"web/icons/Icon-maskable-{size}.png")
            print(f"✓ Généré: web/icons/Icon-maskable-{size}.png")
            success_count += 1
        except Exception as e:
            print(f"❌ Erreur: {e}")

    print(f"\n🎉 Génération terminée: {success_count}/{total_count} icônes générées avec succès!")

    if success_count < total_count:
        print("\n⚠️  Certaines icônes n'ont pas pu être générées.")
    else:
        print("\n✨ Toutes les icônes ont été générées avec succès!")
        print("🎵 Nouveau design avec barres d'égaliseur représentant les chansons")

if __name__ == "__main__":
    main()
