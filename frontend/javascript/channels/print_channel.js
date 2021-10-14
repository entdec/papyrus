import consumer from "./consumer"
window.zip = require("!!!@zip.js/zip.js/dist/zip-full")

consumer.subscriptions.create(
  { channel: "Papyrus::PrintChannel" },
  {
    connected() {
      const self = this
      this.update()
      this.install()

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
      this.uninstall()
    },

    // Called when the subscription is rejected by the server.
    rejected() {
      this.uninstall()
    },

    update() {
      if (!document.hidden && document.hasFocus()) {
        this.active = true
      } else {
        this.active = false
      }
    },

    install() {
      window.addEventListener("focus", this.update)
      document.addEventListener("blur", this.update)
      document.addEventListener("turbo:load", this.update)

      document.addEventListener("visibilitychange", this.update)
    },

    uninstall() {
      window.removeEventListener("focus", this.update)
      document.removeEventListener("blur", this.update)
      document.removeEventListener("turbo:load", this.update)

      document.removeEventListener("visibilitychange", this.update)
    },

    printersList(data) {
      this.perform("printers_list", { printersList: data })
    },

    received(job) {
      const self = this

      if (!this.active) {
        return
      }

      if (JSPM.JSPrintManager.websocket_status == JSPM.WSStatus.Open) {
        var cpj = new JSPM.ClientPrintJob()
        cpj.clientPrinter = new JSPM.InstalledPrinter(job.printer)

        if (job.kind == "raw") {
          fetch(job.url, { redirect: "follow" })
            .then(self.handleErrors)
            .then((response) => {
              response.text().then(function (data) {
                cpj.printerCommands = data
                cpj.printerCommandsCopies = job.copies
                self.spoolJob(cpj, job.id)
              })
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
      const self = this

      // There is also onError and onFinished, but these are not reliably called.
      // The state-description is 'Completed', still need to know about other states.
      cpj.onUpdated = function (data) {
        // console.log("Print Job Update: ", data)
        if (data["state-description"] === "Completed") {
          self.perform("printed", { print_job_id: job_id })
        } else if (data["state-description"] === "Error") {
          self.perform("errored", { print_job_id: job_id })
        }
      }

      cpj.sendToClient().then((data) => {
        self.perform("printing", { print_job_id: job_id })
      })
    },
  }
)
