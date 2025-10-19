import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    goBack(event) {
        event.preventDefault()
        history.back()
    }
}
