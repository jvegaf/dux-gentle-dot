import QtQuick
import QtQuick.Controls as Controls
import qs.Common

import "bridge/attachments.mjs" as Attachments

// A pending protocol Ask. All responses use the service's validated answer path;
// no optimistic removal: other clients and timeouts resolve through the daemon.
FocusScope {
  id: card

  required property var ask
  property var client: null
  property color foreground: Theme.surfaceText
  property color urgent: Theme.error
  property string fontFamily: Theme.fontFamily
  readonly property bool appOnly: ask.method === "app" || ask.method === "pin"
  readonly property Item focusTarget: appOnly ? null
    : ask.method === "input" ? input
    : ask.method === "editor" ? editor
    : ask.method === "confirm" ? yes
    : options.count > 0 ? options.itemAt(0) : cancel
  property string answerError: ""

  implicitHeight: contents.implicitHeight + Theme.spacingL

  // The ask comes from the daemon: links open only when they are web links (http, https), never
  // file:// or other schemes that start local applications (S22.1).
  function openLink(link) {
    if (!/^https?:\/\//i.test(String(link || ""))) return false
    Qt.openUrlExternally(link)
    return true
  }

  function respond(payload) {
    if (!client) return
    var result = client.answer(ask.requestId, payload)
    answerError = result === "sent" ? "" : "Could not answer: " + result
  }

  Rectangle {
    anchors.fill: parent
    radius: Theme.cornerRadius
    color: Qt.rgba(card.foreground.r, card.foreground.g, card.foreground.b, 0.06)
    border.color: card.urgent
    border.width: 1
  }

  Column {
    id: contents
    x: Theme.spacingM
    y: Theme.spacingM
    width: card.width - Theme.spacingL
    spacing: Theme.spacingS

    Text {
      width: parent.width
      text: String(card.ask.title || "Gentle Dot needs you")
      textFormat: Text.PlainText
      wrapMode: Text.Wrap
      color: card.foreground
      font.family: card.fontFamily
      font.pixelSize: Theme.fontSizeMedium
      font.bold: true
    }

    TextEdit {
      visible: text !== ""
      width: parent.width
      objectName: "askMessage"
      // Qt's Markdown would load images (local files included) from image syntax and HTML.
      text: Attachments.markdownText(String(card.ask.message || ""))
      textFormat: TextEdit.MarkdownText
      readOnly: true
      selectByMouse: true
      wrapMode: TextEdit.Wrap
      color: card.foreground
      font.family: card.fontFamily
      font.pixelSize: Theme.fontSizeMedium
      onLinkActivated: function(link) { card.openLink(link) }
    }

    Text {
      visible: card.appOnly
      width: parent.width
      text: "Answer this in the Gentle Dot app"
      wrapMode: Text.Wrap
      color: card.urgent
      font.family: card.fontFamily
      font.pixelSize: Theme.fontSizeMedium
    }

    Column {
      visible: card.ask.method === "select"
      width: parent.width
      spacing: Theme.spacingXS
      Repeater {
        id: options
        model: card.ask.method === "select" ? (card.ask.options || []) : []
        Button {
          required property string modelData
          width: parent.width
          text: modelData
          foreground: card.foreground
          fontFamily: card.fontFamily
          focusable: true
          bordered: true
          onClicked: card.respond({value: modelData})
        }
      }
    }

    Row {
      visible: card.ask.method === "confirm"
      spacing: Theme.spacingS
      Button {
        id: yes
        text: "Yes"
        foreground: card.foreground
        fontFamily: card.fontFamily
        focusable: true
        bordered: true
        onClicked: card.respond({confirmed: true})
      }
      Button {
        text: "No"
        foreground: card.foreground
        fontFamily: card.fontFamily
        focusable: true
        bordered: true
        onClicked: card.respond({confirmed: false})
      }
    }

    Controls.TextField {
      id: input
      visible: card.ask.method === "input"
      width: parent.width
      color: card.foreground
      placeholderTextColor: Qt.darker(card.foreground, 1.4)
      selectionColor: Theme.primaryContainer
      selectedTextColor: card.foreground
      font.family: card.fontFamily
      font.pixelSize: Theme.fontSizeMedium
      leftPadding: Theme.spacingS
      rightPadding: Theme.spacingS
      text: String(card.ask.prefill || "")
      placeholderText: String(card.ask.placeholder || "")
      onAccepted: card.respond({value: text})
      background: Rectangle {
        color: "transparent"
        border.color: input.activeFocus ? card.urgent : Qt.darker(card.foreground, 1.4)
        radius: Theme.cornerRadius
      }
    }

    Controls.ScrollView {
      visible: card.ask.method === "editor"
      width: parent.width
      height: 130
      clip: true
      Controls.TextArea {
        id: editor
        text: String(card.ask.prefill || "")
        placeholderText: String(card.ask.placeholder || "")
        wrapMode: TextEdit.Wrap
        selectByMouse: true
        color: card.foreground
        placeholderTextColor: Qt.darker(card.foreground, 1.4)
        font.family: card.fontFamily
        font.pixelSize: Theme.fontSizeMedium
        background: Rectangle {
          color: "transparent"
          border.color: editor.activeFocus ? card.urgent : Qt.darker(card.foreground, 1.4)
          radius: Theme.cornerRadius
        }
      }
    }

    Row {
      visible: !card.appOnly
      spacing: Theme.spacingS
      Button {
        visible: card.ask.method === "input" || card.ask.method === "editor"
        text: "Submit"
        foreground: card.foreground
        fontFamily: card.fontFamily
        focusable: true
        bordered: true
        onClicked: card.respond({value: card.ask.method === "editor" ? editor.text : input.text})
      }
      Button {
        id: cancel
        text: "Cancel"
        foreground: card.foreground
        fontFamily: card.fontFamily
        focusable: true
        bordered: true
        onClicked: card.respond({cancelled: true})
      }
    }

    Text {
      visible: text !== ""
      width: parent.width
      text: card.answerError
      textFormat: Text.PlainText
      wrapMode: Text.Wrap
      color: card.urgent
      font.family: card.fontFamily
      font.pixelSize: Theme.fontSizeSmall
    }
  }
}
