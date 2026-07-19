import QtQuick
import QtMultimedia

Item {
    id: videoContainer
    anchors.fill: parent

    property url videoSource: ""
    property bool started: false
    property bool failed: false
    property string errorMessage: ""

    signal playbackStarted()
    signal playbackFailed(string message)
    signal mediaStatusReported(string statusText)

    function statusName(status) {
        switch (status) {
        case MediaPlayer.NoMedia: return "NoMedia"
        case MediaPlayer.LoadingMedia: return "LoadingMedia"
        case MediaPlayer.LoadedMedia: return "LoadedMedia"
        case MediaPlayer.StalledMedia: return "StalledMedia"
        case MediaPlayer.BufferingMedia: return "BufferingMedia"
        case MediaPlayer.BufferedMedia: return "BufferedMedia"
        case MediaPlayer.EndOfMedia: return "EndOfMedia"
        case MediaPlayer.InvalidMedia: return "InvalidMedia"
        default: return "UnknownMediaStatus(" + status + ")"
        }
    }

    function start() {
        started = false
        failed = false
        errorMessage = ""

        var sourceText = videoSource.toString()
        if (sourceText.length === 0) {
            failed = true
            errorMessage = "La ruta del video está vacía"
            playbackFailed(errorMessage)
            return
        }

        console.log("Intentando reproducir video:", sourceText)
        player.stop()
        player.source = videoSource

        // setSource es asíncrono; posponer play evita iniciar durante el mismo
        // ciclo en el que se reemplazó la URL.
        Qt.callLater(function() {
            player.play()
        })
    }

    MediaPlayer {
        id: player
        loops: MediaPlayer.Infinite
        videoOutput: videoOutput
        audioOutput: backgroundAudio

        onPlayingChanged: {
            if (playing && !videoContainer.started) {
                videoContainer.started = true
                videoContainer.failed = false
                videoContainer.errorMessage = ""
                videoContainer.playbackStarted()
            }
        }

        onMediaStatusChanged: {
            var text = videoContainer.statusName(mediaStatus)
            videoContainer.mediaStatusReported(text)

            if (mediaStatus === MediaPlayer.InvalidMedia) {
                videoContainer.started = false
                videoContainer.failed = true
                videoContainer.errorMessage = errorString.length > 0
                    ? errorString
                    : "El archivo multimedia no es válido"
                videoContainer.playbackFailed(videoContainer.errorMessage)
            }
        }

        onErrorOccurred: function(error, errorString) {
            videoContainer.started = false
            videoContainer.failed = true
            videoContainer.errorMessage = errorString.length > 0
                ? errorString
                : "Qt Multimedia no pudo reproducir el video (error " + error + ")"
            videoContainer.playbackFailed(videoContainer.errorMessage)
        }
    }

    AudioOutput {
        id: backgroundAudio
        muted: true
    }

    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
    }
}