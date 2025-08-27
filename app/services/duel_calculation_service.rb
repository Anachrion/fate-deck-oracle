class DuelCalculationService

  FATE_DECK = (1..13).to_a * 4 + [0, 14]

  def initialize(attacker_stat:, defender_stat:, attacker_flips: [], defender_flips: [])
    @attacker_stat = attacker_stat
    @defender_stat = defender_stat
    @attacker_flips = attacker_flips
    @defender_flips = defender_flips
  end
  
  attr_reader :attacker_stat, :defender_stat, :attacker_flips, :defender_flips

  def call 
    
    attacker_combinations = process_combinations(flips: attacker_flips)
    defender_combinations = process_combinations(flips: defender_flips)

    result = []

    attacker_combinations.each do |attacker_draw_value|
      defender_combinations.each do |defender_draw_value|
        result << (attacker_draw_value + attacker_stat) - (defender_draw_value + defender_stat)
      end
    end

    global_success_rate = ((result.count { |value| value >= 0 } / result.size.to_f) * 100).round
    global_success_rate_with_raise = ((result.count { |value| value >= 5 } / result.size.to_f) * 100).round

    {
      global_success_rate:,
      global_success_rate_with_raise:
    }
  end


  def process_combinations(flips:)
    number_of_cards, flip_symbol = check_flips_consistency(flips:) 

    draw_results = combinations(number_of_cards: number_of_cards)

    draw_final_values = draw_results.map do |combination|
      determine_draw_value(cards: combination, flip: flip_symbol)
    end
    
    draw_final_values
  end

  # Flips are an array of symbols, either :+ or :-
  def check_flips_consistency(flips:)
    return [1, nil] if flips.empty?

    raise "Unknown flip value" if (@attacker_flips+@defender_flips).any? { |flip| ![:+, :-].include?(flip) }
    raise "You can't mix positive and negative flips" if (@attacker_flips.uniq.length > 1) || (@defender_flips.uniq.length > 1)
    [flips.length + 1, flips.first]
  end

  def combinations(number_of_cards:)
    FATE_DECK.combination(number_of_cards).to_a
  end

  def determine_draw_value(cards:, flip: nil)
    raise "Inconsistent params" if cards.size > 1 && flip.nil?

    # If only one card is drawn, return the value of the card
    return cards.first if cards.one?

    # Black joker
    return 0 if cards.include?(0)

    # Red joker
    return 14 if cards.include?(14)

    if flip == :+
      cards.max
    elsif flip == :-
      cards.min
    end
  end

 
end
