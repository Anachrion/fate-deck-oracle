import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "targetNumberInput"]

  connect() {
    console.log("DuelType controller connected")
    console.log("Targets found:", {
      input: this.hasInputTarget,
      inputField: this.hasTargetNumberInputTarget
    })
    // Set initial state - default to opposed duel (middle button)
    this.selectType({ currentTarget: this.element.querySelector('[data-duel-type="opposed"]') })
  }

  selectType(event) {
    console.log("selectType called with:", event.currentTarget.dataset.duelType)
    const selectedType = event.currentTarget.dataset.duelType
    const allButtons = this.element.querySelectorAll('.duel-type-btn')
    
    // Update hidden input value
    this.inputTarget.value = selectedType
    console.log("Updated input value to:", selectedType)
    
    // Show/hide target number section based on duel type
    if (selectedType === 'simple' || selectedType === 'opposed_with_tn') {
      console.log("Showing target number elements")
      this.targetNumberInputTarget.classList.remove('hidden')
    } else {
      console.log("Hiding target number elements")
      this.targetNumberInputTarget.classList.add('hidden')
    }
    
    // Update button styles
    allButtons.forEach(btn => {
      if (btn.dataset.duelType === selectedType) {
        btn.classList.add('bg-gradient-to-r', 'from-purple-600', 'to-blue-600', 'text-white', 'shadow-lg')
        btn.classList.remove('text-slate-300', 'hover:text-white', 'hover:bg-white/20')
      } else {
        btn.classList.remove('bg-gradient-to-r', 'from-purple-600', 'to-blue-600', 'text-white', 'shadow-lg')
        btn.classList.add('text-slate-300', 'hover:text-white', 'hover:bg-white/20')
      }
    })
  }
}
