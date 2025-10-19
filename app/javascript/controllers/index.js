// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application"

// Register controllers manually to avoid import.meta issues
// You can add more controllers here as needed
import AdminPackageModalController from "./admin_package_modal_controller"
import CustomerPackageModalController from "./customer_package_modal_controller"
import ApplicationController from "./application_controller"

application.register("admin-package-modal", AdminPackageModalController)
application.register("customer-package-modal", CustomerPackageModalController)
application.register("application", ApplicationController)

// Import admin order handlers
import "../admin_order_handlers"
