import { definitionsFromContext } from "stimulus/webpack-helpers"
import { Application } from "stimulus"

// https://www.neodynamic.com/Products/Help/JSPrintManager3.0/apiref/modules/jspm.html
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

    console.log("Papyrus")
    console.log("License URL", JSPM.JSPrintManager.license_url)

    this.application = application
    const context = require.context("./controllers", true, /\.js$/)
    this.application.load(definitionsFromContext(context))

    import("./channels")
  }
}
