import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mpris as Mpris

PlasmoidItem {
    id: root

    // Mismo modelo que usa el reproductor oficial de Plasma: junta todas las
    // apps MPRIS (Spotify, Elisa, VLC, navegadores...) y elige la activa.
    Mpris.Mpris2Model { id: mpris }

    readonly property var player: mpris.currentPlayer
    readonly property alias model: mpris

    readonly property string track: player?.track ?? ""
    readonly property string artist: player?.artist ?? ""
    readonly property string album: player?.album ?? ""
    readonly property string albumArt: player?.artUrl ?? ""
    readonly property string identity: player?.identity ?? ""
    readonly property string playerIcon: player?.iconName ?? "multimedia-player"
    readonly property bool canControl: player?.canControl ?? false
    readonly property bool canGoPrevious: player?.canGoPrevious ?? false
    readonly property bool canGoNext: player?.canGoNext ?? false
    readonly property bool canPlay: player?.canPlay ?? false
    readonly property bool canPause: player?.canPause ?? false
    readonly property bool canSeek: player?.canSeek ?? false
    readonly property bool canRaise: player?.canRaise ?? false
    readonly property int playbackStatus: player?.playbackStatus ?? 0
    readonly property int shuffle: player?.shuffle ?? 0
    readonly property int loopStatus: player?.loopStatus ?? 0
    readonly property bool isPlaying: playbackStatus === Mpris.PlaybackStatus.Playing
    readonly property bool hasMedia: !!player && playbackStatus > Mpris.PlaybackStatus.Stopped && track !== ""

    function togglePlaying() {
        if (!player) return
        if (isPlaying) { if (canPause) player.Pause() }
        else if (canPlay) player.Play()
    }
    function previous() { if (canGoPrevious) player.Previous() }
    function next() { if (canGoNext) player.Next() }
    function raise() { if (canRaise) player.Raise() }
    function changeVolume(delta) { player?.changeVolume(delta, true) }

    function toggleShuffle() {
        player.shuffle = shuffle === Mpris.ShuffleStatus.On
            ? Mpris.ShuffleStatus.Off : Mpris.ShuffleStatus.On
    }
    function cycleLoop() {
        switch (loopStatus) {
        case Mpris.LoopStatus.Playlist: player.loopStatus = Mpris.LoopStatus.Track; break
        case Mpris.LoopStatus.Track:    player.loopStatus = Mpris.LoopStatus.None; break
        default:                        player.loopStatus = Mpris.LoopStatus.Playlist
        }
    }

    Plasmoid.icon: isPlaying ? "media-playback-playing" : "multimedia-player"
    Plasmoid.title: "Reproductor de música"
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    // En el panel o la bandeja se oculta cuando no hay nada sonando.
    Plasmoid.status: hasMedia ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus

    toolTipMainText: hasMedia ? track : "Nada sonando"
    toolTipSubText: hasMedia ? [artist, identity].filter(s => s).join(" · ") : ""

    // Compacto solo en paneles; en el escritorio (o en ventana) la tarjeta completa.
    readonly property bool inPanel: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
                                 || Plasmoid.formFactor === PlasmaCore.Types.Vertical
    preferredRepresentation: inPanel ? compactRepresentation : fullRepresentation

    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}
}
