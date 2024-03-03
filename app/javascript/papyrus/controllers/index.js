import { application } from "papyrus/controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

eagerLoadControllersFrom("papyrus/controllers", application)
