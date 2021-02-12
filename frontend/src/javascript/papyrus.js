import "../style/papyrus.scss"

import { definitionsFromContext } from "stimulus/webpack-helpers"
import { Application } from "stimulus"
import { JSPM } from "jsprintmanager"
export class Papyrus {
  static start(application) {
    if (!application) {
      application = Application.start()
    }
    console.log("Papyrus")
    this.application = application
    const context = require.context("./controllers", true, /\.js$/)
    this.application.load(definitionsFromContext(context))

    console.log("JSPM")
    JSPM.JSPrintManager.auto_reconnect = true
    JSPM.JSPrintManager.start()
    JSPM.JSPrintManager.WS.onStatusChanged = function () {
      if (JSPM.JSPrintManager.websocket_status == JSPM.WSStatus.Open) {
        JSPM.JSPrintManager.getPrinters().then(function (e) {
          console.log(e)
        })
      }
    }
  }
}
