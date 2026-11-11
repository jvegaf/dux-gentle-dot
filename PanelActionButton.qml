import QtQuick.Controls
import QtQuick
import qs.Common

Rectangle {
  id: root
  property string iconText: ""
  property string tooltipText: ""
  property color foreground: Theme.surfaceText
  property color hoverColor: Theme.primary
  property string fontFamily: Theme.fontFamily
  property bool bordered: false
  signal clicked()

  implicitWidth: 28
  implicitHeight: 28
  radius: Theme.cornerRadius
  color: mouse.containsMouse ? Qt.rgba(hoverColor.r, hoverColor.g, hoverColor.b, 0.15) : "transparent"
  border.width: bordered ? 1 : 0
  border.color: Theme.outlineVariant
  opacity: enabled ? 1 : 0.5

  Text {
    anchors.centerIn: parent
    text: root.iconText
    color: mouse.containsMouse ? root.hoverColor : root.foreground
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

  ToolTip.visible: mouse.containsMouse && root.tooltipText !== ""
  ToolTip.text: root.tooltipText
  ToolTip.delay: 500
}
