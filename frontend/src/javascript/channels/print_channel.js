import consumer from "./consumer"

import JSPM from "jsprintmanager"

consumer.subscriptions.create(
  { channel: "Papyrus::PrintChannel" },
  {
    connected() {
      const self = this
      console.log("connected to print channel")
      // Called when the subscription is ready for use on the server
      JSPM.JSPrintManager.auto_reconnect = true
      JSPM.JSPrintManager.start()
      JSPM.JSPrintManager.WS.onStatusChanged = function () {
        if (JSPM.JSPrintManager.websocket_status == JSPM.WSStatus.Open) {
          console.log("JSPM is running")

          JSPM.JSPrintManager.getPrintersInfo().then(function (printersList) {
            console.log(printersList)
            self.printersList(printersList)
          })
        } else if (JSPM.JSPrintManager.websocket_status == JSPM.WSStatus.Closed) {
          console.log("JSPM is not installed or not running!")
        } else if (JSPM.JSPrintManager.websocket_status == JSPM.WSStatus.Blocked) {
          console.log("JSPM has blocked this website!")
        }
      }
    },

    disconnected() {
      // Called when the subscription has been terminated by the server
    },

    printersList(data) {
      this.perform("printers_list", { printersList: data })
    },

    received(data) {
      const self = this
      if (JSPM.JSPrintManager.websocket_status == JSPM.WSStatus.Open) {
        var cpj = new JSPM.ClientPrintJob()
        cpj.clientPrinter = new JSPM.DefaultPrinter()

        var my_file1 = new JSPM.PrintFilePDF("/files/LoremIpsum.pdf", JSPM.FileSourceType.URL, "MyFile.pdf", 1)
        cpj.files.push(my_file1)

        var my_file2 = new JSPM.PrintFileTXT("/files/LoremIpsum.txt", "MyFile.txt", 1, JSPM.FileSourceType.URL)
        cpj.files.push(my_file2)

        var my_file = new JSPM.PrintFile("/images/penguins300dpi.jpg", JSPM.FileSourceType.URL, "MyFile.jpg", 1)
        cpj.files.push(my_file)

        cpj.onUpdated = function (data) {
          console.info(data)
        }

        cpj.onFinished = function (data) {
          console.info(data)
        }

        cpj.sendToClient()

        var cpj = new JSPM.ClientPrintJob()
        cpj.clientPrinter = new JSPM.DefaultPrinter()
        cpj.printerCommands = "RAW PRINTER COMMANDS HERE"
        cpj.sendToClient()
      }
    },
  }
)
