import QtQuick
import qs.Common
import qs.Common

import "bridge/attachments.mjs" as Attachments

// One file as a small chip: thumbnail (local images only), name, size, an optional muted
// note ("preview unavailable") and, in the composer, a remove ×.
Rectangle {
  id: chip
  objectName: "attachmentChip"

  property string name: ""
  property real size: 0
  property string mime: ""
  // Local file, when this client has the bytes; empty for history from elsewhere.
  property string path: ""
  property string note: ""
  property bool removable: false
  property color foreground: Theme.surfaceText
  property string fontFamily: Theme.fontFamily
  property real maximumWidth: 240
  readonly property bool preview: path !== "" && Attachments.isImage(mime)
  readonly property color muted: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.6)
  signal removed()

  width: Math.min(maximumWidth, row.implicitWidth + Theme.spacingM)
  height: Math.max(Theme.spacingL, row.implicitHeight + Theme.spacingS)
  radius: Theme.cornerRadius
  color: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.08)

  Row {
    id: row
    x: Theme.spacingXS
    anchors.verticalCenter: parent.verticalCenter
    spacing: Theme.spacingXS

    Image {
      objectName: "chipThumb"
      visible: chip.preview
      anchors.verticalCenter: parent.verticalCenter
      width: Theme.spacingL
      height: Theme.spacingL
      source: chip.preview ? "file://" + encodeURI(chip.path) : ""
      sourceSize.width: 64
      sourceSize.height: 64
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      cache: true
    }
    Text {
      visible: !chip.preview
      anchors.verticalCenter: parent.verticalCenter
      text: Attachments.isImage(chip.mime) ? "󰋩" : "󰈔"
      color: chip.muted
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: Theme.fontSizeSmall + 2
    }
    Column {
      anchors.verticalCenter: parent.verticalCenter
      Text {
        objectName: "chipName"
        width: Math.min(implicitWidth, chip.maximumWidth - 90)
        text: chip.name
        elide: Text.ElideMiddle
        textFormat: Text.PlainText
        color: chip.foreground
        font.family: chip.fontFamily
        font.pixelSize: Theme.fontSizeSmall
      }
      Row {
        spacing: Theme.spacingXS
        Text {
          objectName: "chipSize"
          text: Attachments.formatSize(chip.size)
          textFormat: Text.PlainText
          color: chip.muted
          font.family: chip.fontFamily
          font.pixelSize: Theme.fontSizeSmall - 1
        }
        Text {
          objectName: "chipNote"
          visible: text !== ""
          text: chip.note
          textFormat: Text.PlainText
          color: chip.muted
          font.family: chip.fontFamily
          font.pixelSize: Theme.fontSizeSmall - 1
          font.italic: true
        }
      }
    }
    PanelActionButton {
      objectName: "chipRemove"
      visible: chip.removable
      anchors.verticalCenter: parent.verticalCenter
      iconText: "󰅖"
      tooltipText: "Remove " + chip.name
      foreground: chip.muted
      hoverColor: Theme.error
      fontFamily: "JetBrainsMono Nerd Font"
      fontSize: Theme.fontSizeSmall + 1
      onClicked: chip.removed()
    }
  }
}
