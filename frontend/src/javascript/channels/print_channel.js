import consumer from "./consumer"

import JSPM from "jsprintmanager"

// import * as zip from "@zip.js/zip.js/dist/zip.min.js"
// import * as zip from "@zip.js/zip.js/dist/zip-fs-full.min.js"

// import * as zip from "./jsprintmanager-deps/zip"
// import "./jsprintmanager-deps/zip-ext"
// import "./jsprintmanager-deps/deflate"

import cptables from "./jsprintmanager-deps/cptable"
import cputils from "./jsprintmanager-deps/cputils"

// window.zip = zip

window.cptables = cptables
window.cputils = cputils

consumer.subscriptions.create(
  { channel: "Papyrus::PrintChannel" },
  {
    connected() {
      const self = this
      // Called when the subscription is ready for use on the server
      JSPM.JSPrintManager.auto_reconnect = true
      JSPM.JSPrintManager.start()
      JSPM.JSPrintManager.WS.onStatusChanged = function () {
        if (JSPM.JSPrintManager.websocket_status == JSPM.WSStatus.Open) {
          console.log("Print client application is running")

          JSPM.JSPrintManager.getPrintersInfo().then(function (printersList) {
            self.printersList(printersList)
          })
        } else if (JSPM.JSPrintManager.websocket_status == JSPM.WSStatus.Closed) {
          console.log("Print client application is not installed or not running!")
        } else if (JSPM.JSPrintManager.websocket_status == JSPM.WSStatus.Blocked) {
          console.log("Print client application has blocked this website!")
        }
      }
    },

    disconnected() {
      // Called when the subscription has been terminated by the server
    },

    printersList(data) {
      this.perform("printers_list", { printersList: data })
    },

    received(job) {
      console.log(job)
      const self = this
      if (JSPM.JSPrintManager.websocket_status == JSPM.WSStatus.Open) {
        var cpj = new JSPM.ClientPrintJob()
        cpj.clientPrinter = new JSPM.InstalledPrinter(job.printer)

        if (job.kind == "raw") {
          cpj.printerCommands = "RAW PRINTER COMMANDS HERE"
        } else {
          cpj.files.push(new JSPM["PrintFile" + job.kind.toUpperCase()](job.url, JSPM.FileSourceType.URL, job.filename, job.copies))
        }

        cpj.onUpdated = function (data) {
          console.info(data)
        }

        cpj.onFinished = function (data) {
          console.info(data)
        }

        cpj.sendToClient()
      }
    },
  }
)
