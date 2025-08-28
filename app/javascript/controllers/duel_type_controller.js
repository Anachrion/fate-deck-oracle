import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "targetNumberInput", "defenderInput", "toggleContainer"]

  connect() {
    console.log("DuelType controller connected")
    console.log("Targets found:", {
      input: this.hasInputTarget,
      targetNumberInput: this.hasTargetNumberInputTarget,
      defenderInput: this.hasDefenderInputTarget,
      toggleContainer: this.hasToggleContainerTarget
    })
    
    // Check if all required targets are present
    if (!this.hasInputTarget || !this.hasTargetNumberInputTarget || !this.hasDefenderInputTarget || !this.hasToggleContainerTarget) {
      console.error("Missing required targets:", {
        input: this.hasInputTarget,
        targetNumberInput: this.hasTargetNumberInputTarget,
        defenderInput: this.hasDefenderInputTarget,
        toggleContainer: this.hasToggleContainerTarget
      })
      return
    }
    
    // Set initial state - default to opposed duel (middle button)
    // This will ensure target number is hidden and defender is visible initially
    const defaultButton = this.element.querySelector('[data-duel-type="opposed"]')
    if (defaultButton) {
      this.selectType({ currentTarget: defaultButton })
    } else {
      console.error("Could not find default opposed duel button")
    }
  }

  selectType(event) {
    console.log("selectType called with:", event.currentTarget.dataset.duelType)
    const selectedType = event.currentTarget.dataset.duelType
    const allButtons = this.element.querySelectorAll('.duel-type-btn')
    
    // Update hidden input value
    this.inputTarget.value = selectedType
    console.log("Updated input value to:", selectedType)
    
    // Update the toggle container data-active attribute for the sliding indicator
    this.toggleContainerTarget.setAttribute('data-active', selectedType)
    
    // Get the input fields
    const defenderStatInput = this.defenderInputTarget.querySelector('input[name="defender_stat"]')
    const targetNumberInput = this.targetNumberInputTarget.querySelector('input[name="target_number"]')
    
    // Show/hide inputs based on duel type
    switch (selectedType) {
      case 'simple':
        // Simple duel: show attacker + TN, hide defender
        console.log("Simple duel: showing attacker + TN, hiding defender")
        this.targetNumberInputTarget.classList.remove('hidden')
        this.defenderInputTarget.classList.add('hidden')
        // Remove required attribute for defender in simple duel
        if (defenderStatInput) {
          defenderStatInput.removeAttribute('required')
        }
        // Add required attribute for target number in simple duel
        if (targetNumberInput) {
          targetNumberInput.setAttribute('required', 'required')
        }
        break
      case 'opposed':
        // Opposed duel: show attacker + defender, hide TN
        console.log("Opposed duel: showing attacker + defender, hiding TN")
        this.targetNumberInputTarget.classList.add('hidden')
        this.defenderInputTarget.classList.remove('hidden')
        // Add required attribute for defender in opposed duel
        if (defenderStatInput) {
          defenderStatInput.setAttribute('required', 'required')
        }
        // Remove required attribute for target number in opposed duel
        if (targetNumberInput) {
          targetNumberInput.removeAttribute('required')
        }
        break
      case 'opposed_with_tn':
        // Opposed + TN: show attacker + defender + TN
        console.log("Opposed + TN: showing attacker + defender + TN")
        this.targetNumberInputTarget.classList.remove('hidden')
        this.defenderInputTarget.classList.remove('hidden')
        // Add required attribute for defender in opposed + TN duel
        if (defenderStatInput) {
          defenderStatInput.setAttribute('required', 'required')
        }
        // Add required attribute for target number in opposed + TN duel
        if (targetNumberInput) {
          targetNumberInput.setAttribute('required', 'required')
        }
        break
    }
    
    // Update button styles
    allButtons.forEach(btn => {
      if (btn.dataset.duelType === selectedType) {
        btn.classList.add('active')
      } else {
        btn.classList.remove('active')
      }
    })
  }
}
