import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets
import qs.services
import qs.store

Item {
    id: root

    readonly property var activeTimers: TimerService.timers

    Layout.margins: Padding.normal
    Layout.fillHeight: true
    Layout.preferredWidth: timerContent.implicitWidth + Padding.massive
    visible: activeTimers.length > 0

    RowLayout {
        id: timerContent

        anchors.centerIn: parent
        spacing: Padding.verylarge

        Repeater {
            model: root.activeTimers

            delegate: Item {
                id: timerItem

                implicitWidth: 50
                Layout.fillHeight: true

                CircularProgress {
                    anchors.centerIn: parent
                    value: (modelData.originalDuration - modelData.remainingTime) / modelData.originalDuration

                    size: root.height - Padding.normal
                    lineWidth: 6
                    secondaryColor: "transparent"
                    primaryColor: modelData.color || Colors.m3.m3secondary

                    Symbol {
                        anchors.centerIn: parent
                        fill: 1
                        text: modelData.isRunning ? "pause" : "play_arrow"
                        font.pixelSize: 20
                        color: Colors.m3.m3secondary
                    }

                    MouseArea {
                        id: mouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                        onClicked: mouse => {
                            if (mouse.button === Qt.MiddleButton) {
                                TimerService.removeTimer(modelData.id);
                            } else if (mouse.button === Qt.LeftButton) {
                                if (modelData.isRunning)
                                    TimerService.pauseTimer(modelData.id);
                                else if (modelData.isPaused)
                                    TimerService.startTimer(modelData.id);
                            }
                        }
                        StyledToolTip {
                            extraVisibleCondition: mouse.containsMouse
                            content: TimerService.formatTime(modelData.remainingTime) + " remaining on " + modelData.name
                        }
                    }
                }

                Rectangle {
                    visible: index < root.activeTimers.length - 1
                    anchors.top: parent.top
                    anchors.bottom: parent
                    anchors.left: timerRect.right
                    anchors.margins: Padding.normal
                    anchors.verticalCenter: parent.verticalCenter
                    width: 2
                    color: Colors.colOutline
                }
            }
        }
    }
}
