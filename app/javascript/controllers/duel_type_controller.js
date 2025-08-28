import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "targetNumberSection"]

  connect() {
    // Set initial state - default to opposed duel
    this.selectType({ currentTarget: this.element.querySelector('[data-duel-type="opposed"]') })
  }

  selectType(event) {
    const selectedType = event.currentTarget.dataset.duelType
    const allButtons = this.element.querySelectorAll('.duel-type-btn')
    
    // Update hidden input value
    this.inputTarget.value = selectedType
    
    // Show/hide target number section
    if (selectedType === 'simple') {
      this.targetNumberSectionTarget.style.display = 'flex'
    } else {
      this.targetNumberSectionTarget.style.display = 'none'
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
