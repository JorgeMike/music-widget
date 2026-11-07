# Reproductor de música — widget para KDE Plasma 6

Plasmoide con un reproductor moderno para cualquier app compatible con MPRIS: Spotify, Elisa, VLC, mpv, Brave, Firefox, Chrome…

## Capturas

| Portada oscura | Portada clara |
|---|---|
| ![Widget reproduciendo Dangerous](screenshots/widget-1.png) | ![Widget reproduciendo Clima Tropical](screenshots/widget-2.png) |

El fondo y el color de la barra de progreso se adaptan a cada portada.

## Qué hace

- Portada con esquinas redondeadas y, de fondo, la misma portada desenfocada.
- Toma el color de acento de la portada para la barra de progreso y el brillo del botón de play.
- Barra de progreso que se puede arrastrar o clicar para adelantar.
- Botones de anterior, play/pausa, siguiente, aleatorio y repetir (lista → canción → apagado).
- Rueda del mouse sobre el widget para subir o bajar el volumen (sale el OSD de Plasma).
- Clic en la portada para traer al frente la app que está sonando.
- Si tienes varias apps reproduciendo, aparecen sus íconos arriba a la derecha para cambiar entre ellas.
- **En el panel** se ve la miniatura de la portada con barritas animadas:
  - Clic: abre la tarjeta completa.
  - Clic medio: play/pausa.
  - Rueda: volumen.
  - Botones atrás/adelante del mouse: canción anterior/siguiente.
  - Se oculta solo cuando no hay nada sonando.

## Requisitos

- KDE Plasma 6.0 o superior.

## Instalación

```bash
cd music-widget
kpackagetool6 --type Plasma/Applet --install .
```

Después: clic derecho en el escritorio o en el panel → **Añadir o gestionar widgets** → busca **Reproductor de música**.

### Actualizar

```bash
kpackagetool6 --type Plasma/Applet --upgrade .
```

Si no ves los cambios, reinicia Plasma:

```bash
systemctl --user restart plasma-plasmashell
```

### Probar en una ventana sin tocar el escritorio

```bash
plasmawindowed local.musicplayer
```

### Desinstalar

```bash
kpackagetool6 --type Plasma/Applet --remove local.musicplayer
```

## Archivos

| Archivo | Para qué |
|---|---|
| `contents/ui/main.qml` | Conexión con MPRIS y acciones (play, siguiente, volumen…) |
| `contents/ui/FullRepresentation.qml` | La tarjeta completa |
| `contents/ui/CompactRepresentation.qml` | La miniatura del panel |
| `contents/ui/SeekBar.qml` | Barra de progreso |
| `contents/ui/ControlButton.qml` | Botones redondos |
| `contents/ui/RoundedImage.qml` | Portada con esquinas redondeadas |
| `contents/ui/Equalizer.qml` | Barritas animadas |
