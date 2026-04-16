import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.common.widgets
import qs.services

Item {
    id: root
    ColumnLayout {
        anchors.fill: parent
        spacing: Padding.huge

        SoundItemContainer {
            height: 72
            radius: Rounding.verylarge
            Layout.fillWidth: true
            soundId: ""
            soundVolume: AmbientSoundsService.states.masterVolume
            playerPlaying: false
            effectivePlaying: !AmbientSoundsService.states.masterPaused
            soundInfo: null
            isMaster: true
            isActive: true
        }

        StyledListView {
            id: activeList
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: Padding.normal
            model: AmbientSoundsService.states.activeSounds
            delegate: SoundItemContainer {
                required property var modelData
                required property int index
                property var _soundInfo: AmbientSoundsService.states.availableSounds.find(s => s.id === modelData.id)
                height: 72
                topRadius: index === 0 ? Rounding.verylarge : Rounding.tiny
                bottomRadius: index === AmbientSoundsService.states.activeSounds.length - 1 ? Rounding.verylarge : Rounding.tiny
                anchors.right: parent?.right
                anchors.left: parent?.left
                soundId: modelData.id
                soundVolume: modelData.volume
                playerPlaying: modelData.isPlaying ?? false
                effectivePlaying: (modelData.isPlaying ?? false) && !AmbientSoundsService.states.masterPaused
                soundInfo: _soundInfo ?? null
                isMaster: false
                isActive: true
            }
            PagePlaceholder {
                z: -1
                anchors.centerIn: parent
                shown: AmbientSoundsService.states.activeSounds.length === 0
                icon: "relax"
                title: "There are no Active Sounds"
                description: "Swipe below to show available sounds"
            }
        }
    }
    BottomDialog {
        enableStagedReveal: true
        bottomAreaReveal: true
        hoverHeight: 200
        collapsedHeight: parent.height * 0.6
        contentItem: AvilableSoundsList {}
    }
}
