import { definitionsFromContext } from "stimulus/webpack-helpers"
import { Application } from "stimulus"
import { log } from "./utils"

import JSPM from "jsprintmanager"

export class Papyrus {
  static start(application) {
    if (!application) {
      application = Application.start()
    }

    // FIXME: This needs papyrus mounted in /papers
    JSPM.JSPrintManager.license_url = `${location.protocol}//${location.host}/papers/print_client_license`
    JSPM.JSPrintManager.auto_reconnect = true
    JSPM.JSPrintManager.start()

    log("Papyrus")

    this.application = application
    const context = require.context("./controllers", true, /\.js$/)
    this.application.load(definitionsFromContext(context))

    import("./channels")
  }
}
