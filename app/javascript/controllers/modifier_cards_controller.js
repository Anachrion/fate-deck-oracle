import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["attackerModPositive", "attackerModNegative", "defenderModPositive", "defenderModNegative", "attackerModInput", "defenderModInput", "attackerModIndicators", "defenderModIndicators"]
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
    
    const values = ["--", "-", "", "+", "++"]
    let index = values.indexOf(currentValue)
    let newIndex = Math.min(values.length - 1, index + 1) // Never go above array bounds
    let newValue = values[newIndex]
    
    input.value = newValue
    this.updateCardDisplay()
    
    // Flash the positive card with green color briefly AFTER updating display
    setTimeout(() => {
      this.flashCard(target, "positive")
    }, 50) // Small delay to ensure updateCardDisplay completes first
  }

  addNegative(event) {
    const target = event.currentTarget
    const inputTargetName = target.dataset.inputTarget
    const input = this[inputTargetName + "Target"]
    const currentValue = input.value || ""
    
    const values = ["--", "-", "", "+", "++"]
    let index = values.indexOf(currentValue)
    let newIndex = Math.max(0, index - 1) // Never go below 0
    let newValue = values[newIndex]
    
    input.value = newValue
    this.updateCardDisplay()
    
    // Flash the negative card with red color briefly AFTER updating display
    setTimeout(() => {
      this.flashCard(target, "negative")
    }, 50) // Small delay to ensure updateCardDisplay completes first
  }

  updateCardDisplay() {
    // Update attacker modifier display
    this.updateModifierDisplay(this.attackerModInputTarget.value, this.attackerModPositiveTarget, this.attackerModNegativeTarget)
    
    // Update defender modifier display
    this.updateModifierDisplay(this.defenderModInputTarget.value, this.defenderModPositiveTarget, this.defenderModNegativeTarget)
    
    // Update indicator cards
    this.updateIndicators()
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

  updateIndicators() {
    // Update attacker indicators based on attacker's own modifier
    this.updateInputIndicators(this.attackerModInputTarget.value, this.attackerModIndicatorsTarget)
    
    // Update defender indicators based on defender's own modifier
    this.updateInputIndicators(this.defenderModInputTarget.value, this.defenderModIndicatorsTarget)
  }

  updateInputIndicators(modifierValue, indicatorsContainer) {
    // Clear existing indicators
    indicatorsContainer.innerHTML = ""
    
    if (modifierValue === "+") {
      // Add one positive indicator
      this.addIndicator(indicatorsContainer, "positive", "+")
    } else if (modifierValue === "++") {
      // Add two positive indicators
      this.addIndicator(indicatorsContainer, "positive", "+")
      this.addIndicator(indicatorsContainer, "positive", "+")
    } else if (modifierValue === "-") {
      // Add one negative indicator
      this.addIndicator(indicatorsContainer, "negative", "-")
    } else if (modifierValue === "--") {
      // Add two negative indicators
      this.addIndicator(indicatorsContainer, "negative", "-")
      this.addIndicator(indicatorsContainer, "negative", "-")
    }
    // If modifierValue is "", no indicators are shown
  }

  addIndicator(container, type, symbol) {
    const indicator = document.createElement("div")
    indicator.className = `modifier-indicator ${type}`
    indicator.textContent = symbol
    container.appendChild(indicator)
  }

  flashCard(card, type) {
    console.log(`Flashing card with type: ${type}`)
    console.log('Card element:', card)
    console.log('Card classes before:', card.className)
    
    // Add flash class for immediate color change
    card.classList.add(`flash-${type}`)
    console.log('Card classes after adding flash:', card.className)
    
    // Remove flash class after 300ms to fade back to original color
    setTimeout(() => {
      console.log(`Removing flash-${type} class`)
      card.classList.remove(`flash-${type}`)
      console.log('Card classes after removing flash:', card.className)
    }, 300)
  }
}
