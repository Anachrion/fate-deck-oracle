import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["attackerModPositive", "attackerModNegative", "defenderModPositive", "defenderModNegative", "attackerModInput", "defenderModInput"]
  static values = { 
    attackerMod: String, 
    defenderMod: String
  }

  connect() {
    this.updateCardDisplay()
  }

  addPositive(event) {
    const target = event.currentTarget
    const inputTargetName = target.dataset.inputTarget
    const input = this[inputTargetName + "Target"]
    const currentValue = input.value || ""
    
    // Move right in the cycle: "--" → "-" → "" → "+" → "++"
    let newValue = ""
    
    if (currentValue === "" || currentValue === "-" || currentValue === "--") {
      newValue = "+"
    } else if (currentValue === "+") {
      newValue = "++"
    } else if (currentValue === "++") {
      newValue = "++" // Already at max, stay there
    }
    
    input.value = newValue
    this.updateCardDisplay()
  }

  addNegative(event) {
    const target = event.currentTarget
    const inputTargetName = target.dataset.inputTarget
    const input = this[inputTargetName + "Target"]
    const currentValue = input.value || ""
    
    // Move left in the cycle: "++" → "+" → "" → "-" → "--"
    let newValue = ""
    
    if (currentValue === "" || currentValue === "+" || currentValue === "++") {
      newValue = "-"
    } else if (currentValue === "-") {
      newValue = "--"
    } else if (currentValue === "--") {
      newValue = "--" // Already at max, stay there
    }
    
    input.value = newValue
    this.updateCardDisplay()
  }

  updateCardDisplay() {
    // Update attacker modifier display
    this.updateModifierDisplay(this.attackerModInputTarget.value, this.attackerModPositiveTarget, this.attackerModNegativeTarget)
    
    // Update defender modifier display
    this.updateModifierDisplay(this.defenderModInputTarget.value, this.defenderModPositiveTarget, this.defenderModNegativeTarget)
  }

  updateModifierDisplay(value, positiveCard, negativeCard) {
    // Remove all existing classes from both cards
    positiveCard.classList.remove("inactive", "single-positive", "double-positive", "single-negative", "double-negative")
    negativeCard.classList.remove("inactive", "single-positive", "double-positive", "single-negative", "double-negative")
    
    // Add appropriate classes based on value
    if (value === "") {
      positiveCard.classList.add("inactive")
      negativeCard.classList.add("inactive")
    } else if (value === "+") {
      positiveCard.classList.add("single-positive")
      negativeCard.classList.add("inactive")
    } else if (value === "++") {
      positiveCard.classList.add("double-positive")
      negativeCard.classList.add("inactive")
    } else if (value === "-") {
      positiveCard.classList.add("inactive")
      negativeCard.classList.add("single-negative")
    } else if (value === "--") {
      positiveCard.classList.add("inactive")
      negativeCard.classList.add("double-negative")
    }
  }
}
