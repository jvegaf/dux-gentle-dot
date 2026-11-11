import QtQuick
import qs.Common

Rectangle {
  id: root
  property string text: ""
  property string icon: ""
  property color foreground: Theme.surfaceText
  property color background: Theme.primary
  property color hoverColor: Qt.lighter(background, 1.1)
  property string fontFamily: Theme.fontFamily
  property bool bordered: false
  property bool flat: false
  property bool focusable: false
  signal clicked()

  focus: focusable
  activeFocusOnTab: focusable
  Keys.onReturnPressed: if (enabled) root.clicked()
  Keys.onEnterPressed: if (enabled) root.clicked()
  Keys.onSpacePressed: if (enabled) root.clicked()

  implicitWidth: label.implicitWidth + Theme.spacingL * 2
  implicitHeight: Math.max(32, label.implicitHeight + Theme.spacingS * 2)
  radius: Theme.cornerRadius
  color: flat ? "transparent" : (mouse.containsMouse ? hoverColor : background)
  border.width: activeFocus ? 2 : (bordered || flat ? 1 : 0)
  border.color: activeFocus ? Theme.primary : bordered ? foreground : (flat ? Theme.outlineVariant : "transparent")
  opacity: enabled ? 1 : 0.5

  Text {
    id: label
    anchors.centerIn: parent
    text: (root.icon ? root.icon + " " : "") + root.text
    color: flat ? root.foreground : Theme.surfaceText
    font.family: root.fontFamily
    font.pixelSize: Theme.fontSizeMedium
    textFormat: Text.PlainText
  }

  MouseArea {
    id: mouse
    anchors.fill: parent
    hoverEnabled: true
    onClicked: if (root.enabled) root.clicked()
  }
}
