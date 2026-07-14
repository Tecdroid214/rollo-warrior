// VideoBackground.qml
import QtQuick 2.15
import QtMultimedia 5.15

Item {
    id: videoContainer
    anchors.fill: parent

    property string videoSource: ""

    MediaPlayer {
        id: bgPlayer
        source: videoSource
        loops: MediaPlayer.Infinite
        autoPlay: true
        videoOutput: bgVideoOutput
    }

    VideoOutput {
        id: bgVideoOutput
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
    }
}