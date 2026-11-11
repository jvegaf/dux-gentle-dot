import QtQuick
import qs.Common
import qs.Common
// Always-visible action list, separate from the assistant's answer card.
Column {
  id: root
  property var activities: []
  readonly property int count: rows.count
  // Derive secondary text from foreground: some themes have a very dark muted token.
  readonly property color muted: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.65)
  spacing: 3

  function sourceFor(a) {
    if (a.source) return a.source
    var kinds = {memory:"engram", read:"files", edit:"files", write:"files", file:"files", command:"shell", shell:"shell", search:"web", web:"web", subagent:"subagent", mcp:"mcp", ask:"ask"}
    return kinds[a.kind] || "other"
  }
  function iconFor(a) {
    var icons = {engram:"🧠", slack:"\uf198", linear:"📐", gmail:"\udb80\udeab", notion:"📝", atlassian:"\udb80\udf03", discord:"\udb81\ude6f", rdd:"🛡️", web:"🌐", files:"📄", shell:"⌨️", subagent:"🤝", mcp:"🔌", other:"⚙️", ask:"❓"}
    if (sourceFor(a) === "files" && /edit|write/.test(a.kind)) return "✏️"
    return icons[sourceFor(a)] || icons.other
  }
  function sourceColorFor(a) {
    var palette = {engram:"#c4a7e7", slack:"#ee6690", linear:"#a6a0ff", gmail:"#ea7369", notion:"#cdd6f4", atlassian:"#74adff", discord:"#8e9aff", rdd:"#f5bde6", web:"#8bd5e8", files:"#a6d6b2", shell:"#edc8a3", subagent:"#f4b8a4", mcp:"#94e2d5", other:"#a5a2b8", ask:"#f6c177"}
    if (sourceFor(a) === "files" && /edit|write/.test(a.kind)) return "#f6c177"
    return palette[sourceFor(a)] || palette.other
  }
  function iconColorFor(a) { return sourceColorFor(a) }
  function statusFor(a) { return a.status === "running" ? "◌" : (a.status === "failed" ? "✗" : "✓") }
  function statusColorFor(a) { return a.status === "running" ? Theme.primary : (a.status === "failed" ? Theme.error : root.muted) }
  function titleFor(a) { return a.kind === "ask" ? "Asking you" : String(a.title || a.tool || a.kind || "Activity") }

  Repeater {
    id: rows
    model: root.activities
    Item {
      id: row
      objectName: "activityRow"
      required property var modelData
      property bool detailsOpen: false
      readonly property bool hasDetails: !!(modelData.detail || modelData.output)
      // The bridge's per-tool view (S21); older bridges send none and keep the raw text below.
      readonly property var view: modelData.view || null
      readonly property bool hasView: !!(view && (view.detail || view.output))
      width: root.width
      implicitHeight: content.implicitHeight
      Rectangle {
        width: 2
        height: parent.height
        color: root.sourceColorFor(row.modelData)
      }
      Column {
        id: content
        x: Theme.spacingS
        width: parent.width - x
        spacing: 3
        Rectangle {
          width: parent.width
          height: Math.max(22, activityTitle.implicitHeight + Theme.spacingXS)
          color: activityMouse.containsMouse && row.hasDetails ? Theme.surfaceContainerHighest : "transparent"
          MouseArea {
            id: activityMouse
            objectName: "activityHit"
            anchors.fill: parent
            enabled: row.hasDetails
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: row.detailsOpen = !row.detailsOpen
          }
          Text {
            id: activityIcon
            width: 22
            anchors.verticalCenter: parent.verticalCenter
            text: root.iconFor(row.modelData)
            textFormat: Text.PlainText
            color: root.iconColorFor(row.modelData)
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Theme.fontSizeSmall + 2
          }
          Text {
            id: activityTitle
            anchors.left: activityIcon.right; anchors.right: status.left
            anchors.rightMargin: Theme.spacingS; anchors.verticalCenter: parent.verticalCenter
            text: root.titleFor(row.modelData) + (row.hasDetails ? (row.detailsOpen ? "  󰅀" : "  󰅂") : "")
            textFormat: Text.PlainText
            elide: Text.ElideRight
            color: root.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
          }
          Text {
            id: status
            anchors.right: parent.right; anchors.rightMargin: Theme.spacingXS
            anchors.verticalCenter: parent.verticalCenter
            text: root.statusFor(row.modelData)
            color: root.statusColorFor(row.modelData)
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
          }
        }
        Loader {
          width: parent.width
          active: row.detailsOpen && row.hasView && !!row.view.detail
          visible: active
          sourceComponent: ActivityDetail { objectName: "activityDetailView"; view: row.view.detail; muted: root.muted }
        }
        Loader {
          width: parent.width
          active: row.detailsOpen && row.hasView && !!row.view.output
          visible: active
          sourceComponent: ActivityDetail { objectName: "activityOutputView"; view: row.view.output; muted: root.muted }
        }
        TextEdit {
          objectName: "activityDetail"
          width: parent.width
          visible: row.detailsOpen && !row.hasView && text !== ""
          text: String(row.modelData.detail || "")
          textFormat: TextEdit.PlainText
          readOnly: true
          selectByMouse: true
          wrapMode: TextEdit.Wrap
          color: root.muted
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: Theme.fontSizeSmall
        }
        TextEdit {
          objectName: "activityOutput"
          width: parent.width
          visible: row.detailsOpen && !row.hasView && text !== ""
          text: String(row.modelData.output || "")
          textFormat: TextEdit.PlainText
          readOnly: true
          selectByMouse: true
          wrapMode: TextEdit.Wrap
          color: root.muted
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: Theme.fontSizeSmall
        }
      }
    }
  }
}
