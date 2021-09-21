import { definitionsFromContext } from "stimulus/webpack-helpers"
import { Application } from "stimulus"

// https://www.neodynamic.com/Products/Help/JSPrintManager4.0/apiref/modules/jspm.html
import JSPM from "jsprintmanager"
window.JSPM = JSPM

export class Papyrus {
  static start(application, startPrintManager = false, autoReconnect = false) {
    if (!application) {
      application = Application.start()
    }

    console.log("Papyrus")

    this.application = application
    const context = require.context("./controllers", true, /\.js$/)
    this.application.load(definitionsFromContext(context))

    if (startPrintManager) {
      // FIXME: This needs papyrus mounted in /papers
      JSPM.JSPrintManager.license_url = `${location.protocol}//${location.host}/papers/print_client_license`
      JSPM.JSPrintManager.auto_reconnect = autoReconnect
      JSPM.JSPrintManager.start()
      console.log("JSPM version:", JSPM.VERSION)
      import("./channels")
    }
  }
}
