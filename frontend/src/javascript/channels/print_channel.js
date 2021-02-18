import consumer from "./consumer"

import JSPM from "jsprintmanager"

import "imports-loader?wrapper=window!../vendor/zip.js"
import "imports-loader?wrapper=window!../vendor/zip-ext.js"
import "imports-loader?wrapper=window!../vendor/deflate.js"

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
          fetch(job.url)
            .then(self.handleErrors)
            .then((response) => {
              cpj.printerCommands = response
              self.spoolJob(cpj, job.id)
            })
            .catch((error) => {
              console.log(error)
            })
        } else {
          cpj.files.push(new JSPM["PrintFile" + job.kind.toUpperCase()](job.url, JSPM.FileSourceType.URL, job.filename, job.copies))
          self.spoolJob(cpj, job.id)
        }
      }
    },

    // Handle errors with regards to getting the raw data
    handleErrors(response) {
      if (!response.ok) throw new Error(response.status)
      return response
    },

    // Spool job to the printer
    spoolJob(cpj, job_id) {
      cpj.onError = function (data) {
        self.perform("errored", { job_id: job_id })
      }

      cpj.onUpdated = function (data) {
        self.perform("printing", { job_id: job_id })
      }

      cpj.onFinished = function (data) {
        self.perform("printed", { job_id: job_id })
      }

      cpj.sendToClient()
    },
  }
)
