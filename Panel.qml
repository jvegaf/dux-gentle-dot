import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Modules.Plugins
import qs.Services
import qs.Widgets
import qs.Common
import qs.Common

PluginComponent {
  id: root

  pluginId: "gentle-dot"
  pluginService: PluginService

  readonly property var client: PluginService.pluginDaemonInstances[pluginId] ?? null

  readonly property color foreground: Theme.surfaceText
  readonly property color urgent: Theme.error
  readonly property color dim: Qt.darker(foreground, 1.4)
  readonly property string fontFamily: Theme.fontFamily
  readonly property color panelBackground: {
    var base = Theme.surfaceContainerHigh
    return Qt.rgba(base.r, base.g, base.b, base.a * (client ? client.panelOpacity : 0.95))
  }

  readonly property bool pinned: client ? client.panelPinned : false
  readonly property bool detached: client ? client.detached : false
  readonly property bool ownsDetached: detached && client.detachedOwner === root
  readonly property bool settingsOpen: client && client.view === "settings"
  readonly property string connection: client ? client.connection : "stopped"
  readonly property bool connected: client ? client.connected : false
  readonly property string agentState: connected ? client.agentState : ""
  readonly property string model: client ? client.model : ""
  readonly property bool fatal: connection === "fatal"
  readonly property bool busy: client ? client.busy : false
  readonly property bool needsYou: agentState === "needs_you"
  readonly property bool modelMissing: connected && (model === "" || model === "unknown")
  readonly property color statusColor: {
    if (fatal || needsYou) return urgent
    if (busy) return Theme.primary
    return foreground
  }

  function connectionLabel() {
    switch (connection) {
      case "connecting": return "Connecting"
      case "open": return connected ? "Connected" : "Signing in"
      case "reconnecting": return "Reconnecting"
      case "fatal": return "Disconnected"
      default: return client ? "Stopped" : "Starting"
    }
  }

  function agentLabel() {
    switch (agentState) {
      case "starting": return "Starting"
      case "idle": return "Idle"
      case "thinking": return "Thinking"
      case "working": return "Working"
      case "needs_you": return "Needs you"
      case "restarting": return "Restarting"
      case "error": return "Error"
      default: return ""
    }
  }

  function stateLine() {
    var agent = agentLabel()
    return (agent ? connectionLabel() + "  ·  " + agent : connectionLabel()).toUpperCase()
  }

  function pushSettings() {
    if (!client) return
    var pd = pluginData || {}
    function setting(name, fallback) { return pd[name] !== undefined ? pd[name] : fallback }
    client.configure({
      nodePath: setting("nodePath", "node"),
      serverUrl: setting("serverUrl", "ws://127.0.0.1:4317/ws"),
      tokenFile: setting("tokenFile", "~/.gentle-dot/token"),
      voiceSendOnStop: setting("voiceSendOnStop", false),
      notifications: setting("notifications", true),
      notificationSound: setting("notificationSound", true),
      panelOpacity: setting("panelOpacity", 0.95),
      avatarSleepMinutes: setting("avatarSleepMinutes", 30)
    })
  }

  function webUrl() {
    var url = client ? client.serverUrl : ""
    var match = url.match(/^ws(s?):\/\/([^\/?#]+)/)
    return match ? "http" + match[1] + "://" + match[2] : "http://127.0.0.1:4317"
  }

  function togglePanel() {
    if (detached) {
      if (!client.detachedOwner) client.detachedOwner = root
      showDetached()
    } else if (pinned) {
      // sticky window stays; no popout toggle
    } else {
      root.expanded = !root.expanded
    }
  }

  function showDetached() {
    detachedWindow.minimized = false
  }

  function dock(showPopup) {
    if (!client) return
    client.setDetached(false, null)
    if (showPopup) root.expanded = true
  }

  onClientChanged: pushSettings()
  onPluginDataChanged: pushSettings()
  Component.onCompleted: pushSettings()

  readonly property bool contentOpen: root.expanded || ownsDetached || pinned
  onContentOpenChanged: if (client) client.reportPanelOpen(root, contentOpen)
  onDetachedChanged: if (detached && root.expanded) root.expanded = false

  Component.onDestruction: {
    if (client) client.reportPanelVisibility(root, false)
    if (client) client.reportPanelOpen(root, false)
    if (client && client.detachedOwner === root) client.setDetached(false, null)
  }

  horizontalBarPill: Component {
    StyledRect {
      implicitHeight: Theme.barHeight
      implicitWidth: pillRow.implicitWidth + Theme.spacingM
      radius: Theme.cornerRadius
      color: Theme.surfaceContainerHigh

      Row {
        id: pillRow
        anchors.centerIn: parent
        spacing: Theme.spacingXS

        Item {
          width: Theme.iconSize
          height: Theme.iconSize
          anchors.verticalCenter: parent.verticalCenter

          Image {
            id: barRose
            anchors.centerIn: parent
            width: Theme.iconSizeSmall
            height: Theme.iconSizeSmall
            source: Qt.resolvedUrl("assets/rose-dualtone-136.png")
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: root.connected || root.fatal ? 1 : 0.45
          }
          Rectangle {
            visible: root.fatal || root.needsYou || root.busy
            width: 6; height: 6; radius: 3
            color: root.statusColor
            border.width: 1
            border.color: Theme.background
            anchors.right: barRose.right
            anchors.bottom: barRose.bottom
            anchors.rightMargin: -2
            anchors.bottomMargin: -1
          }
        }

        StyledText {
          visible: root.fatal || root.needsYou || root.busy
          text: root.fatal ? "!" : (root.needsYou ? "?" : "…")
          color: root.statusColor
          font.pixelSize: Theme.fontSizeSmall
          anchors.verticalCenter: parent.verticalCenter
        }
      }

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
          if (mouse.button === Qt.RightButton && root.fatal && root.client) root.client.restart()
          else root.togglePanel()
        }
      }
    }
  }

  verticalBarPill: Component {
    StyledRect {
      implicitWidth: Theme.barHeight
      implicitHeight: Theme.barHeight
      radius: Theme.cornerRadius
      color: Theme.surfaceContainerHigh

      Item {
        anchors.centerIn: parent
        width: Theme.iconSizeSmall
        height: Theme.iconSizeSmall
        Image {
          anchors.fill: parent
          source: Qt.resolvedUrl("assets/rose-dualtone-136.png")
          fillMode: Image.PreserveAspectFit
          smooth: true
          opacity: root.connected || root.fatal ? 1 : 0.45
        }
        Rectangle {
          visible: root.fatal || root.needsYou || root.busy
          width: 6; height: 6; radius: 3
          color: root.statusColor
          anchors.right: parent.right
          anchors.bottom: parent.bottom
        }
      }

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
          if (mouse.button === Qt.RightButton && root.fatal && root.client) root.client.restart()
          else root.togglePanel()
        }
      }
    }
  }

  popoutWidth: 560
  popoutHeight: 700

  popoutContent: Component {
    PopoutComponent {
      id: popout
      headerText: "Gentle Dot"
      showCloseButton: false

      Item {
        id: popoutBody
        width: parent.width
        height: 640

        // Reuse full chat/settings UI inline for popout
        Loader {
          anchors.fill: parent
          sourceComponent: mainUiComponent
        }
      }
    }
  }

  // Main UI shared between popout, sticky, and detached modes
  Component {
    id: mainUiComponent
    Item {
      id: uiRoot
      anchors.fill: parent

      Column {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Theme.spacingM

        PanelHero {
          width: parent.width
          title: root.client ? root.client.headerTitle : "Gentle Dot"
          meta: root.stateLine()
          detail: root.model === "unknown" ? "" : (root.model || "")
          foreground: root.foreground
          fontFamily: root.fontFamily

          iconComponent: Component {
            Item {
              implicitWidth: Theme.fontSizeXLarge
              implicitHeight: Theme.fontSizeXLarge
              Image {
                anchors.fill: parent
                source: Qt.resolvedUrl("assets/rose-dualtone-136.png")
                fillMode: Image.PreserveAspectFit
                smooth: true
                opacity: root.connected || root.fatal ? 1 : 0.45
              }
              Rectangle {
                visible: root.fatal || root.needsYou || root.busy
                width: 8; height: 8; radius: 4
                color: root.statusColor
                border.width: 1
                border.color: Theme.background
                anchors.right: parent.right
                anchors.bottom: parent.bottom
              }
            }
          }
        }

        Row {
          anchors.right: parent.right
          spacing: Theme.spacingXS

          PanelActionButton {
            iconText: root.client ? root.client.privacyIcon : ""
            tooltipText: root.client ? root.client.privacyTooltip : ""
            foreground: root.foreground
            fontFamily: root.fontFamily
            onClicked: if (root.client) root.client.setPrivacyMasked(!root.client.privacyMasked)
          }

          PanelActionButton {
            iconText: root.settingsOpen ? "󰁍" : "󰒓"
            tooltipText: root.settingsOpen ? "Back to chat" : "Settings"
            foreground: root.foreground
            fontFamily: root.fontFamily
            onClicked: if (root.client) root.client.view = root.settingsOpen ? "chat" : "settings"
          }

          PanelActionButton {
            visible: !root.detached
            iconText: root.pinned ? "󰐃" : "󰐄"
            tooltipText: root.pinned ? "Unpin" : "Pin"
            foreground: root.pinned ? Theme.primary : root.foreground
            fontFamily: root.fontFamily
            onClicked: if (root.client) root.client.setPinned(!root.pinned)
          }

          PanelActionButton {
            iconText: root.detached ? "󰖲" : "󰏌"
            tooltipText: root.detached ? "Dock" : "Detach"
            foreground: root.foreground
            fontFamily: root.fontFamily
            onClicked: {
              if (root.detached) root.dock(true)
              else if (root.client) root.client.setDetached(true, root)
            }
          }
        }

        Text {
          visible: !root.settingsOpen && root.modelMissing
          width: parent.width
          text: !root.client ? "" : "Sign in to a model provider in the Gentle Dot web UI (" + root.client.displayUrl(root.webUrl()) + ")"
          color: root.dim
          wrapMode: Text.Wrap
          textFormat: Text.PlainText
          font.family: root.fontFamily
          font.pixelSize: Theme.fontSizeSmall
        }

        PanelSeparator { foreground: root.foreground }
      }

      ChatView {
        id: chat
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.topMargin: Theme.spacingM
        anchors.bottom: footer.top
        anchors.bottomMargin: Theme.spacingS
        visible: !root.settingsOpen && !root.fatal
        model: root.client ? root.client.messages : null
        client: root.client
        foreground: root.foreground
        accent: Theme.primary
        urgent: root.urgent
        fontFamily: root.fontFamily
      }

      Text {
        visible: !root.settingsOpen && !root.fatal && chat.count === 0 && !chat.hasAsks
        anchors.centerIn: chat
        width: chat.width
        text: root.connected ? "Ask Gentle Dot anything" : (root.client ? root.client.displayUrl(root.client.serverUrl) : "")
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Theme.fontSizeMedium
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideMiddle
      }

      Column {
        visible: !root.settingsOpen && root.fatal
        anchors.centerIn: chat
        width: chat.width
        spacing: Theme.spacingM
        Text {
          width: parent.width
          text: root.client ? root.client.displayText(root.client.fatalMessage) : ""
          color: root.urgent
          font.family: root.fontFamily
          font.pixelSize: Theme.fontSizeMedium
          horizontalAlignment: Text.AlignHCenter
          wrapMode: Text.Wrap
        }
        Button {
          anchors.horizontalCenter: parent.horizontalCenter
          text: "Retry"
          foreground: root.foreground
          fontFamily: root.fontFamily
          bordered: true
          onClicked: if (root.client) root.client.restart()
        }
      }

      SettingsView {
        id: settingsView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.topMargin: Theme.spacingM
        anchors.bottom: parent.bottom
        visible: root.settingsOpen
        client: root.client
        foreground: root.foreground
        urgent: root.urgent
        fontFamily: root.fontFamily
      }

      Column {
        id: footer
        visible: !root.settingsOpen
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: Theme.spacingS

        Text {
          visible: root.client !== null && root.client.notice !== ""
          width: parent.width
          text: root.client ? root.client.displayText(root.client.notice) : ""
          color: root.client && (root.client.noticeLevel === "error" || root.client.noticeLevel === "warning") ? root.urgent : root.dim
          wrapMode: Text.Wrap
          textFormat: Text.PlainText
          font.family: root.fontFamily
          font.pixelSize: Theme.fontSizeSmall
        }

        Composer {
          id: composer
          width: parent.width
          client: root.client
          foreground: root.foreground
          urgent: root.urgent
          busy: root.busy
          avatarActive: root.contentOpen
          avatarAlpha: root.panelBackground.a
          font.family: root.fontFamily
          onSent: chat.scrollToEnd()
        }
      }

      DropOverlay {
        anchors.fill: parent
        z: 10
        enabled: !root.settingsOpen
        client: root.client
        foreground: root.foreground
        accent: Theme.primary
        fontFamily: root.fontFamily
      }
    }
  }

  // Sticky pinned window (kept as Quickshell window per S4)
  StickyPanel {
    id: stickyPanel
    anchorItem: root
    bar: null
    open: root.pinned && !root.detached
    contentWidth: 560
    contentHeight: 640
    background: root.panelBackground

    Loader {
      id: stickyLoader
      anchors.fill: stickyPanel.contentContainer
      active: stickyPanel.open
      sourceComponent: mainUiComponent
    }
  }

  // Detached floating window (kept as Quickshell window per S4)
  DetachedWindow {
    id: detachedWindow
    open: root.ownsDetached
    initialWidth: 560
    initialHeight: 640
    background: root.panelBackground
    onDockRequested: root.dock(false)

    Loader {
      id: detachedLoader
      anchors.fill: detachedWindow.contentContainer
      active: detachedWindow.open
      sourceComponent: mainUiComponent
    }
  }

  // Image viewer overlay
  PanelWindow {
    id: viewerWindow
    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    visible: root.contentOpen && !!root.client && root.client.viewerImage !== null
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "gentle-dot-image"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    anchors { top: true; bottom: true; left: true; right: true }

    ImageViewer {
      anchors.fill: parent
      client: root.client
      foreground: root.foreground
      fontFamily: root.fontFamily
    }
  }
}
