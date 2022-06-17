import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"
import { Application } from "@hotwired/stimulus"

export class Papyrus {
  static start(application) {
    if (!application) {
      application = Application.start()
    }

    console.log("Papyrus")

    this.application = application
    const context = require.context("./controllers", true, /\.js$/)
    this.application.load(definitionsFromContext(context))
  }
}
