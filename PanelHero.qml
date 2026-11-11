import QtQuick
import qs.Common

Item {
  id: root
  property string title: ""
  property string meta: ""
  property string detail: ""
  property color foreground: Theme.surfaceText
  property string fontFamily: Theme.fontFamily
  property Component iconComponent: null

  implicitHeight: contentRow.implicitHeight

  Row {
    id: contentRow
    anchors.left: parent.left
    anchors.right: parent.right
    spacing: Theme.spacingM

    Loader {
      id: iconLoader
      sourceComponent: root.iconComponent
      visible: root.iconComponent !== null
      anchors.verticalCenter: parent.verticalCenter
    }

    Column {
      anchors.verticalCenter: parent.verticalCenter
      spacing: Theme.spacingXXS
      width: parent.width - (iconLoader.visible ? iconLoader.width + Theme.spacingM : 0)

      Text {
        text: root.title
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Medium
        textFormat: Text.PlainText
        elide: Text.ElideRight
        width: parent.width
      }
      Text {
        visible: root.meta !== ""
        text: root.meta
        color: Qt.darker(root.foreground, 1.4)
        font.family: root.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        textFormat: Text.PlainText
        elide: Text.ElideRight
        width: parent.width
      }
      Text {
        visible: root.detail !== ""
        text: root.detail
        color: Qt.darker(root.foreground, 1.6)
        font.family: root.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        textFormat: Text.PlainText
        elide: Text.ElideMiddle
        width: parent.width
      }
    }
  }
}
