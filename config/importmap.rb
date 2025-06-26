# Pin npm packages by running ./bin/importmap

pin "application"
pin "admin_navigation"
pin "admin_content_blocks"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Pin controllers manually if needed
# pin "controllers/package_modal_controller", to: "controllers/package_modal_controller.js"
