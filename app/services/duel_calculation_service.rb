class DuelCalculationService
  attr_reader :attacker_value, :defender_value

  def initialize(attacker_value:, defender_value:)
    @attacker_value = attacker_value.to_i
    @defender_value = defender_value.to_i
  end

  def call 
    attacker_value - defender_value
  end

 
end
