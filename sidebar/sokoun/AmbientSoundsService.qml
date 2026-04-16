pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtMultimedia
import Quickshell
import Qt.labs.folderlistmodel
import qs.store
import qs.common
import qs.common.utils

Singleton {
    id: root

    property QtObject states: QtObject {
        property real masterVolume: 1
        property bool masterPaused: false
        property bool muted: false
        property list<var> availableSounds: []
        property list<var> activeSounds: []
    }

    property var players: ({})

    readonly property string audioDir: Directories.plugins.main + "/sidebar/sokoun/sounds"
    readonly property var iconMap: ({
            "rain": "water_drop",
            "storm": "thunderstorm",
            "waves": "waves",
            "ocean": "waves",
            "fire": "local_fire_department",
            "fireplace": "local_fire_department",
            "wind": "air",
            "birds": "flutter_dash",
            "bird": "flutter_dash",
            "stream": "water",
            "river": "water",
            "water": "water",
            "white": "graphic_eq",
            "pink": "graphic_eq",
            "noise": "graphic_eq",
            "coffee": "local_cafe",
            "cafe": "local_cafe",
            "shop": "local_cafe",
            "train": "train",
            "boat": "sailing",
            "ship": "sailing",
            "night": "nightlight",
            "summer": "wb_sunny",
            "city": "location_city",
            "urban": "location_city"
        })

    FolderListModel {
        id: audioFolderModel
        folder: Qt.resolvedUrl(root.audioDir)
        nameFilters: ["*.mp3", "*.wav", "*.ogg", "*.m4a"]
        showDirs: false
        onStatusChanged: if (status === FolderListModel.Ready) {
            scanAudioFiles();
        }
    }

    readonly property Component playerComponent: MediaPlayer {
        loops: MediaPlayer.Infinite
        audioOutput: AudioOutput {}
    }

    Connections {
        target: root.states
        function onMasterVolumeChanged() {
            updateAllVolumes();
        }
        function onMutedChanged() {
            updateAllVolumes();
        }
        function onMasterPausedChanged() {
            updateAllPlayback();
        }
    }

    function playSound(soundId, volume = null) {
        const active = states?.activeSounds ?? [];
        if (active.find(s => s.id === soundId))
            return;

        const available = states?.availableSounds ?? [];
        const sound = available.find(s => s.id === soundId);
        if (!sound)
            return;

        const vol = volume ?? (states?.masterVolume ?? 1);
        const player = playerComponent.createObject(root, {
            source: sound.filePath,
            "audioOutput.volume": calculateVolume(vol)
        });

        if (!player)
            return;

        states.masterPaused ? player.pause() : player.play();
        players[soundId] = player;

        states.activeSounds.push({
            id: soundId,
            volume: vol,
            name: sound.name,
            isPlaying: !states.masterPaused
        });
    }

    function stopSound(soundId) {
        const active = states?.activeSounds ?? [];
        const index = active.findIndex(s => s.id === soundId);
        if (index === -1)
            return;

        const player = players[soundId];
        if (player) {
            player.stop();
            player.destroy();
            delete players[soundId];
        }
        states.activeSounds.splice(index, 1);
    }

    function toggleSound(soundId, volume = null) {
        const active = states?.activeSounds ?? [];
        active.find(s => s.id === soundId) ? stopSound(soundId) : playSound(soundId, volume);
    }

    function toggleSoundPlayback(soundId) {
        const active = states?.activeSounds ?? [];
        const index = active.findIndex(s => s.id === soundId);
        if (index === -1)
            return;

        const player = players[soundId];
        if (!player)
            return;

        const newState = !states.activeSounds[index].isPlaying;
        newState ? player.play() : player.pause();
        states.activeSounds[index].isPlaying = newState;
    }

    function setSoundVolume(soundId, volume) {
        const active = states?.activeSounds ?? [];
        const index = active.findIndex(s => s.id === soundId);
        if (index === -1)
            return;

        const clamped = Math.max(0, Math.min(1, volume));
        states.activeSounds[index].volume = clamped;

        if (players[soundId]) {
            players[soundId].audioOutput.volume = calculateVolume(clamped);
        }
    }

    function toggleMasterPause() {
        if (states)
            states.masterPaused = !states.masterPaused;
    }
    function toggleMute() {
        if (states)
            states.muted = !states.muted;
    }

    function stopAll() {
        const active = states?.activeSounds ?? [];
        for (let i = active.length - 1; i >= 0; i--) {
            stopSound(active[i].id);
        }
        if (states)
            states.masterPaused = false;
    }

    function isPlaying(soundId) {
        const active = states?.activeSounds ?? [];
        return active.find(s => s.id === soundId)?.isPlaying ?? false;
    }

    function refresh() {
        audioFolderModel.folder = "";
        Qt.callLater(() => audioFolderModel.folder = Qt.resolvedUrl(root.audioDir));
    }

    function restorePlayers() {
        Qt.callLater(() => {
            const active = states?.activeSounds ?? [];
            active.forEach(soundData => {
                if (players[soundData.id])
                    return;

                const available = states?.availableSounds ?? [];
                const sound = available.find(s => s.id === soundData.id);
                if (!sound)
                    return;

                const player = playerComponent.createObject(root, {
                    source: sound.filePath,
                    "audioOutput.volume": calculateVolume(soundData.volume)
                });

                if (player) {
                    (soundData.isPlaying && !states.masterPaused) ? player.play() : player.pause();
                    players[soundData.id] = player;
                }
            });
        });
    }

    function scanAudioFiles() {
        const sounds = [];
        for (let i = 0; i < audioFolderModel.count; i++) {
            const fileName = audioFolderModel.get(i, "fileName");
            const nameBase = fileName.replace(/\.[^.]+$/, '');
            sounds.push({
                id: nameBase.toLowerCase().replace(/[^a-z0-9]/g, '_'),
                name: nameBase.replace(/[_-]/g, ' ').split(' ').map(w => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase()).join(' '),
                icon: getIconForName(nameBase.toLowerCase()),
                filePath: audioFolderModel.get(i, "fileUrl"),
                fileName: fileName
            });
        }
        if (states)
            states.availableSounds = sounds;
        restorePlayers();
    }

    function getIconForName(name) {
        for (const key in iconMap) {
            if (name.includes(key))
                return iconMap[key];
        }
        return "music_note";
    }

    function calculateVolume(vol) {
        if (!states)
            return vol;
        return states.muted ? 0 : vol * states.masterVolume;
    }

    function updateAllVolumes() {
        const active = states?.activeSounds ?? [];
        active.forEach(s => {
            if (players[s.id])
                players[s.id].audioOutput.volume = calculateVolume(s.volume);
        });
    }

    function updateAllPlayback() {
        const active = states?.activeSounds ?? [];
        active.forEach(s => {
            if (players[s.id] && s.isPlaying) {
                states.masterPaused ? players[s.id].pause() : players[s.id].play();
            }
        });
    }
}
