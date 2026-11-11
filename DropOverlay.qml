import QtQuick
import qs.Common
import qs.Common
// The chat's one drop target: files from a file manager, or text with no file, dropped
// anywhere on the panel content. Shows "Drop to attach" while a drag is over it; the
// client decides what attaches (Client.dropItems).
Item {
  id: root
  property var client: null
  property color foreground: Theme.surfaceText
  property color accent: Theme.primary
  property string fontFamily: Theme.fontFamily
  property bool dragging: false
  // The popup background tinted with the accent, translucent enough to keep the chat in view.
  readonly property color tint: {
    var mixed = Qt.tint(Theme.surfaceContainerHigh, Qt.rgba(accent.r, accent.g, accent.b, 0.18))
    return Qt.rgba(mixed.r, mixed.g, mixed.b, 0.88)
  }

  // Files (text/uri-list) or text (text/plain, with or without a charset). `keys` lists the
  // drag's formats, also for sources that only offer text/plain;charset=utf-8.
  function accepts(drag) {
    var keys = drag.keys || []
    return drag.hasUrls || drag.hasText
      || keys.some(function(key) { return key === "text/uri-list" || /^text\/plain\b/.test(key) })
  }

  // Handlers for the DropArea's drag events, callable with any object of the same shape.
  function enter(drag) {
    if (!root.client || !accepts(drag)) {
      drag.accepted = false
      return
    }
    drag.accept(Qt.CopyAction)
    dragging = true
  }

  function exit() { dragging = false }
  onEnabledChanged: if (!enabled) dragging = false

  function drop(drop) {
    dragging = false
    if (!root.client) return
    var urls = drop.hasUrls ? drop.urls.map(function(url) { return url.toString() }) : []
    root.client.dropItems(urls, drop.hasText ? drop.text : "")
    drop.accept(Qt.CopyAction)
  }

  DropArea {
    anchors.fill: parent
    onEntered: function(drag) { root.enter(drag) }
    onExited: root.exit()
    onDropped: function(drop) { root.drop(drop) }
  }

  Rectangle {
    objectName: "dropOverlayCard"
    visible: root.dragging
    anchors.fill: parent
    radius: Theme.cornerRadius
    color: root.tint
    border.width: 2
    border.color: root.accent

    Column {
      anchors.centerIn: parent
      spacing: Theme.spacingXS

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "󰏢"
        color: root.accent
        font.family: root.fontFamily
        font.pixelSize: Theme.fontSizeDisplay
      }
      Text {
        objectName: "dropOverlayLabel"
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Drop to attach"
        color: root.accent
        textFormat: Text.PlainText
        font.family: root.fontFamily
        font.pixelSize: Theme.fontSizeLarge
        font.bold: true
      }
    }
  }
}
