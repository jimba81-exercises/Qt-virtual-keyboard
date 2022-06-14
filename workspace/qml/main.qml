import QtQuick 2.10
import QtQuick.Window 2.10
import QtQuick.VirtualKeyboard 2.1
import QtQuick.VirtualKeyboard.Styles 2.1

Window {
    width: 1024
    height: 750
    visible: true

    Rectangle {
        id: textInputContainer
        anchors.top: parent.top
        width: parent.width
        height: 100
        color: 'pink'
        clip: true
        visible: true

        TextInput {
            id: textInput
            anchors.fill: parent
            /*onTextChanged: {
                console.log("TextInput changed: " + textInput.text);
                cppKeyboard.slotKeyboardTextChanged(textInput.text);
            }*/

            onDisplayTextChanged: {
                console.log("DisplayText changed: " + textInput.displayText);
                cppKeyboard.slotKeyboardTextChanged(textInput.displayText);

            }
        }
    }

    InputPanel {
        id: inputPanel
        anchors.fill: parent
        /*width: parent.width
        height: inputPanel.keyboard.style.keyboardHeight*/

        Component.onCompleted: {
            //keyboard.style.keyboardBackground = null;        // the keyboard background
            //keyboard.style.selectionListBackground = null;   // the horizontal bar at the
                                                             // top of the keyboard
            // TODO: Set custom style
            // Refer: https://doc.qt.io/archives/qt-5.11/technical-guide.html#adding-custom-styles
            // Refer: SY2 App
        }

        onActiveChanged: {
            if (!active) {
                // Force to stay active
                inputPanel.active = true;
            }
        }
    }



    /*Slider {
       id: sliderKeyboardHeight
       from: 0
       to: 3000
    }

    Binding {
       target: inputPanel.keyboard.style
       property: 'keyboardDesignHeight'
       value: sliderKeyboardHeight.value
   }*/

    Component.onCompleted: {
        timerSingleShot(100, function () {
            textInput.forceActiveFocus();
        });
    }

    Component {
        id: delayCallerComponent
        Timer {}
    }

    function timerSingleShot(intervalMs, cb) {
        var dealyCaller = delayCallerComponent.createObject(null, { "interval": intervalMs } );
        dealyCaller.triggered.connect( function() {
            cb();
            dealyCaller.destroy();
        });
        dealyCaller.start();
    }
}
