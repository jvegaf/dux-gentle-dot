import QtQuick
import QtQuick.Controls
import Quickshell.Io

import qs.Common
import qs.Common
Rectangle {
  id: root
  property string code: ""
  property string lang: ""
  property string html: ""
  // Header text and code size; action details use a terminal label and the caption size.
  property string label: lang || "code"
  property int fontPixelSize: Theme.fontSizeMedium
  readonly property color muted: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.72)
  property bool expanded: false
  property string copyState: "Copy"
  // Injectable command keeps headless tests off the real Wayland clipboard.
  property var clipboardCommand: ["wl-copy"]
  readonly property int lineCount: code.split("\n").length
  readonly property bool longContent: lineCount > 15
  readonly property string visibleCode: longContent && !expanded ? code.split("\n").slice(0, 15).join("\n") : code
  radius: Theme.cornerRadius
  color: Qt.darker(Theme.background, 1.15)
  implicitHeight: content.implicitHeight + 16

  function copy() {
    if (!clipboard.running) { clipboard.command = root.clipboardCommand; clipboard.running = true }
  }
  FontMetrics { id: metrics; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: root.fontPixelSize }
  Process {
    id: clipboard
    stdinEnabled: true
    onStarted: { write(root.code); stdinEnabled = false }
    onExited: function(exitCode) { root.copyState = exitCode === 0 ? "Copied" : "Copy failed"; stdinEnabled = true }
  }
  Column {
    id: content
    x: 8; y: 8
    width: root.width - 16
    spacing: 6
    Item {
      width: content.width
      height: copyAction.height
      Text {
        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
        text: root.label
        color: root.muted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
      }
      PanelActionButton {
        id: copyAction
        objectName: "codeCopy"
        anchors.right: parent.right
        iconText: root.copyState === "Copied" ? "✓" : "󰆏"
        tooltipText: root.copyState
        foreground: root.copyState === "Copy failed" ? Theme.error : Theme.surfaceText
        fontFamily: "JetBrainsMono Nerd Font"
        onClicked: root.copy()
      }
    }
    Item {
      width: content.width
      height: root.longContent && !root.expanded ? Math.min(source.implicitHeight, metrics.height * 15) : source.implicitHeight
      Flickable {
        anchors.fill: parent
        contentWidth: Math.max(width, source.implicitWidth)
        contentHeight: height
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        acceptedButtons: Qt.NoButton
        ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AsNeeded }
        TextEdit {
          id: source
          readOnly: true
          selectByMouse: true
          wrapMode: TextEdit.NoWrap
          // Clip the full highlighted document rather than truncating span markup.
          textFormat: root.html ? TextEdit.RichText : TextEdit.PlainText
          text: root.html ? "<pre style=\"margin:0; white-space:pre\">" + root.html + "</pre>" : root.code
          color: Theme.surfaceText
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: root.fontPixelSize
        }
      }
      Rectangle {
        anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
        height: 26
        visible: root.longContent && !root.expanded
        gradient: Gradient {
          GradientStop { position: 0; color: Qt.rgba(root.color.r, root.color.g, root.color.b, 0) }
          GradientStop { position: 1; color: root.color }
        }
      }
    }
    Rectangle {
      visible: root.longContent
      width: content.width
      height: Math.max(28, collapseText.implicitHeight + Theme.spacingS)
      radius: Theme.cornerRadius
      color: collapseMouse.containsMouse ? Theme.surfaceContainerHighest : "transparent"
      MouseArea {
        id: collapseMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expanded = !root.expanded
      }
      PanelActionButton {
        id: collapseChevron
        objectName: "codeToggle"
        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
        iconText: root.expanded ? "󰅀" : "󰅂"
        tooltipText: root.expanded ? "Collapse code" : "Expand code"
        fontFamily: "JetBrainsMono Nerd Font"
        onClicked: root.expanded = !root.expanded
      }
      Text {
        id: collapseText
        anchors.left: collapseChevron.right; anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: root.expanded ? "Show fewer lines" : "Show " + (root.lineCount - 15) + " more lines"
        color: root.muted
        elide: Text.ElideRight
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
      }
    }
  }
}
