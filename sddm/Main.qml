//
// [hyprlock-inspired] main.qml for neil SDDM theme
//
// Simplified login screen matching hyprlock's minimalist centered design

import QtQuick 2.0
import SddmComponents 2.0

import "./components"

Rectangle {
  id: root

  // Gruvbox palette (matches theme.conf)
  property color accentColor: "#7daea3"
  property color backgroundColor: "#282828"
  property color foregroundColor: "#d4be98"
  property color darkForeground: "#7c6f64"
  property color inputBg: "#1e1e1e"
  
  property color normalText: foregroundColor
  property color successText: "#a9b665"
  property color failureText: "#ea6962"

  LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
  LayoutMirroring.childrenInherit: true

  TextConstants { id: textConstants }

  signal tryLogin()

  onTryLogin: {
    sddm.login(username_field.text, password_field.text, session_box.index)
  }

  Connections {
    target: sddm

    onLoginSucceeded: {
      status_msg.color = successText
      status_msg.text = "Login successful"
      status_anim.start()
    }

    onLoginFailed: {
      status_msg.color = failureText
      status_msg.text = "Login failed"
      status_anim.start()
    }

    onInformationMessage: {
      status_msg.color = failureText
      status_msg.text = message
      status_anim.start()
    }
  }

  // Wallpaper background (matching hyprlock)
  Repeater {
    model: screenModel

    Item {
      Rectangle {
        x: geometry.x
        y: geometry.y
        width: geometry.width
        height: geometry.height
        color: backgroundColor
      }

      Image {
        x: geometry.x
        y: geometry.y
        width: geometry.width
        height: geometry.height
        source: "background.png"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
      }

      Rectangle {
        x: geometry.x
        y: geometry.y
        width: geometry.width
        height: geometry.height
        color: "#000000"
        opacity: 0.4
      }
    }
  }

  // Centered time display (matching hyprlock)
  Text {
    id: time_label
    x: (parent.width - width) / 2
    y: (parent.height - 300) / 2

    text: new Date().toLocaleTimeString(Qt.locale(), "HH:mm")

    color: normalText
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 64
    font.weight: Font.Normal

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    Timer {
      interval: 1000
      running: true
      repeat: true
      onTriggered: time_label.text = new Date().toLocaleTimeString(Qt.locale(), "HH:mm")
    }
  }

  // Username label (centered, below time)
  Text {
    id: username_label
    x: (parent.width - width) / 2
    y: time_label.y + 80

    text: "@USER@"

    color: normalText
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 20
    font.weight: Font.Normal

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
  }

  // Username input field
  Rectangle {
    id: username_container
    x: (parent.width - 250) / 2
    y: username_label.y + 60
    width: 250
    height: 50

    color: inputBg
    border.color: accentColor
    border.width: 2
    radius: 4

    TextInput {
      id: username_field
      anchors.fill: parent
      anchors.margins: 10

      color: normalText
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 14

      clip: true

      text: sddm.users.length > 0 ? sddm.users[0] : ""

      Keys.onPressed: {
        if (event.key === Qt.Key_Tab) {
          password_field.focus = true
          event.accepted = true
        }
        if ((event.key === Qt.Key_Return) || (event.key === Qt.Key_Enter)) {
          root.tryLogin()
          event.accepted = true
        }
      }

      onFocusChanged: if (focus) selectAll()
    }

    Text {
      visible: username_field.text === ""
      text: "Username"
      color: darkForeground
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 14
      anchors.left: parent.left
      anchors.leftMargin: 10
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  // Password input field
  Rectangle {
    id: password_container
    x: (parent.width - 250) / 2
    y: username_container.y + 70
    width: 250
    height: 50

    color: inputBg
    border.color: accentColor
    border.width: 2
    radius: 4

    TextInput {
      id: password_field
      anchors.fill: parent
      anchors.margins: 10

      color: normalText
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 14
      echoMode: TextInput.Password
      passwordCharacter: "*"

      clip: true

      Keys.onPressed: {
        if (event.key === Qt.Key_Backtab) {
          username_field.focus = true
          event.accepted = true
        }
        if ((event.key === Qt.Key_Return) || (event.key === Qt.Key_Enter)) {
          root.tryLogin()
          event.accepted = true
        }
      }
    }

    Text {
      visible: password_field.text === ""
      text: "Password..."
      color: darkForeground
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 14
      anchors.left: parent.left
      anchors.leftMargin: 10
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  // Session selector (minimized, right side bottom)
  Row {
    x: parent.width - 300
    y: parent.height - 60

    spacing: 10

    Text {
      text: textConstants.session + ":"
      color: normalText
      font.pixelSize: 12
      font.family: "JetBrainsMono Nerd Font"
      verticalAlignment: Text.AlignVCenter
      height: 30
    }

    ComboBox {
      id: session_box
      model: sessionModel
      index: sessionModel.lastIndex

      width: 150
      height: 30

      color: "#3c3836"
      borderColor: darkForeground
      focusColor: accentColor
      textColor: normalText
      menuColor: "#3c3836"

      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 12
    }
  }

  // Login button
  Rectangle {
    id: login_btn
    x: (parent.width - 250) / 2
    y: password_container.y + 70
    width: 250
    height: 45

    color: accentColor
    radius: 4

    Text {
      anchors.centerIn: parent
      text: textConstants.login
      color: backgroundColor
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 14
      font.weight: Font.Bold
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onClicked: root.tryLogin()
      onEntered: parent.color = Qt.lighter(accentColor, 1.1)
      onExited: parent.color = accentColor
    }
  }

  // Status message
  Text {
    id: status_msg
    x: (parent.width - 400) / 2
    y: login_btn.y + 70
    width: 400

    text: ""
    color: normalText
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 12

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    SequentialAnimation {
      id: status_anim
      running: false

      PauseAnimation { duration: 3000 }

      PropertyAnimation {
        target: status_msg
        property: "opacity"
        from: 1.0
        to: 0.0
        duration: 500
      }

      ScriptAction {
        script: status_msg.text = ""
      }

      PropertyAnimation {
        target: status_msg
        property: "opacity"
        from: 0.0
        to: 1.0
        duration: 0
      }
    }
  }

  Component.onCompleted: {
    if (username_field.text === "")
      username_field.focus = true
    else
      password_field.focus = true
  }
}
