import QtQuick
import qs.Common

Rectangle {
  property color foreground: Theme.surfaceText
  width: parent ? parent.width : 100
  height: 1
  color: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.12)
}
