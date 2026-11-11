import QtQuick
import qs.Common

Rectangle {
  id: root
  property int padding: Theme.spacingM
  property var borderSpec: null
  default property alias content: contentHolder.data

  readonly property real contentTopInset: padding
  readonly property real contentRightInset: padding
  readonly property real contentBottomInset: padding
  readonly property real contentLeftInset: padding

  color: Theme.surfaceContainerHigh
  radius: Theme.cornerRadius
  border.width: 1
  border.color: Theme.outlineVariant

  Item {
    id: contentHolder
    anchors.fill: parent
    anchors.margins: root.padding
  }
}
