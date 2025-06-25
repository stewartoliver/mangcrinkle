// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application"

// Register controllers manually to avoid import.meta issues
// You can add more controllers here as needed
import PackageModalController from "./package_modal_controller"
application.register("package-modal", PackageModalController)

// For now, we're handling the package modal functionality in application.js
// so we don't need to register the Stimulus controller
