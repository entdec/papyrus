import { definitionsFromContext } from "stimulus/webpack-helpers"
import { Application } from "stimulus"
import { log } from "./utils"

export class Papyrus {
  static start(application) {
    if (!application) {
      application = Application.start()
    }

    log("Started");

    this.application = application
    const context = require.context("./controllers", true, /\.js$/)
    this.application.load(definitionsFromContext(context));

    log("Instantiating channels");
    import("./channels");
  }
}
