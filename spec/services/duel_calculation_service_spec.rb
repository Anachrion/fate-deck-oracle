# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DuelCalculationService do
  let(:service) do
    described_class.new(
      attacker_stat: 5,
      defender_stat: 3,
      attacker_flips: '',
      defender_flips: ''
    )
  end

  describe 'constants' do
    it 'defines FATE_DECK correctly' do
      expected_deck = (1..13).to_a * 4 + [0, 14]
      expect(described_class::FATE_DECK).to eq(expected_deck)
      expect(described_class::FATE_DECK.length).to eq(54)
    end
  end

  describe '#initialize' do
    it 'sets the correct attributes' do
      expect(service.attacker_stat).to eq(5)
      expect(service.defender_stat).to eq(3)
      expect(service.attacker_flips).to eq('')
      expect(service.defender_flips).to eq('')
      expect(service.target_number).to be_nil
    end

    context 'with simple duel parameters' do
      let(:simple_service) do
        described_class.new(
          attacker_stat: 5,
          target_number: 7,
          attacker_flips: '',
          defender_flips: ''
        )
      end

      it 'sets simple duel attributes correctly' do
        expect(simple_service.attacker_stat).to eq(5)
        expect(simple_service.defender_stat).to be_nil
        expect(simple_service.target_number).to eq(7)
        expect(simple_service.attacker_flips).to eq('')
        expect(simple_service.defender_flips).to eq('')
      end
    end
  end

  describe '#call' do
    context 'with opposed duel (defender_stat present)' do
      it 'calculates success rates correctly' do
        result = service.call
        expect(result).to be_a(Hash)
        expect(result).to have_key(:global_success_rate)
        expect(result).to have_key(:global_success_rate_with_raise)
        expect(result[:global_success_rate]).to be_between(0, 100)
        expect(result[:global_success_rate_with_raise]).to be_between(0, 100)
      end
    end

    context 'with simple duel (target_number present)' do
      let(:simple_service) do
        described_class.new(
          attacker_stat: 5,
          target_number: 7,
          attacker_flips: '',
          defender_flips: ''
        )
      end

      it 'calculates success rates for simple duel' do
        result = simple_service.call
        expect(result).to be_a(Hash)
        expect(result).to have_key(:global_success_rate)
        expect(result).to have_key(:global_success_rate_with_raise)
        expect(result[:global_success_rate]).to be_between(0, 100)
        expect(result[:global_success_rate_with_raise]).to be_between(0, 100)
      end
    end

    context 'with flips' do
      let(:service_with_flips) do
        described_class.new(
          attacker_stat: 5,
          defender_stat: 3,
          attacker_flips: '++',
          defender_flips: '-'
        )
      end

      it 'calculates success rate with flips' do
        result = service_with_flips.call
        expect(result).to be_a(Hash)
        expect(result[:global_success_rate]).to be_between(0, 100)
        expect(result[:global_success_rate_with_raise]).to be_between(0, 100)
      end
    end

    context 'with invalid duel type' do
      let(:invalid_service) do
        described_class.new(
          attacker_stat: 5,
          attacker_flips: '',
          defender_flips: ''
        )
      end

      it 'raises error for unknown duel type' do
        expect { invalid_service.call }.to raise_error(RuntimeError, 'Unknown duel type')
      end
    end

    context 'with extreme stat differences' do
      let(:extreme_attacker_service) do
        described_class.new(
          attacker_stat: 20,
          defender_stat: 1,
          attacker_flips: '',
          defender_flips: ''
        )
      end

      let(:extreme_defender_service) do
        described_class.new(
          attacker_stat: 1,
          defender_stat: 20,
          attacker_flips: '',
          defender_flips: ''
        )
      end

      it 'handles extreme attacker advantage' do
        result = extreme_attacker_service.call
        expect(result[:global_success_rate]).to be > 80
        expect(result[:global_success_rate_with_raise]).to be_between(0, 100)
      end

      it 'handles extreme defender advantage' do
        result = extreme_defender_service.call
        expect(result[:global_success_rate]).to be < 20
        expect(result[:global_success_rate_with_raise]).to be_between(0, 100)
      end
    end
  end

  describe '#check_consistency_params' do
    context 'with valid flips' do
      it 'does not raise error for valid flip strings' do
        expect { service.send(:check_consistency_params) }.not_to raise_error
      end

      it 'does not raise error for empty flip strings' do
        empty_flip_service = described_class.new(
          attacker_stat: 5,
          defender_stat: 3,
          attacker_flips: '',
          defender_flips: ''
        )
        expect { empty_flip_service.send(:check_consistency_params) }.not_to raise_error
      end

      it 'does not raise error for single flip' do
        single_flip_service = described_class.new(
          attacker_stat: 5,
          defender_stat: 3,
          attacker_flips: '+',
          defender_flips: '-'
        )
        expect { single_flip_service.send(:check_consistency_params) }.not_to raise_error
      end

      it 'does not raise error for multiple flips' do
        multiple_flip_service = described_class.new(
          attacker_stat: 5,
          defender_stat: 3,
          attacker_flips: '++',
          defender_flips: '--'
        )
        expect { multiple_flip_service.send(:check_consistency_params) }.not_to raise_error
      end
    end

    context 'with invalid flip values' do
      let(:service_with_invalid_flips) do
        described_class.new(
          attacker_stat: 5,
          defender_stat: 3,
          attacker_flips: 'a',
          defender_flips: ''
        )
      end

      it 'raises error for unknown flip values' do
        expect do
          service_with_invalid_flips.send(:check_consistency_params)
        end.to raise_error(RuntimeError, 'Unknown flip value')
      end

      it 'raises error for numeric flip values' do
        numeric_flip_service = described_class.new(
          attacker_stat: 5,
          defender_stat: 3,
          attacker_flips: '1',
          defender_flips: ''
        )
        expect do
          numeric_flip_service.send(:check_consistency_params)
        end.to raise_error(RuntimeError, 'Unknown flip value')
      end

      it 'raises error for special character flip values' do
        special_char_service = described_class.new(
          attacker_stat: 5,
          defender_stat: 3,
          attacker_flips: '@',
          defender_flips: ''
        )
        expect do
          special_char_service.send(:check_consistency_params)
        end.to raise_error(RuntimeError, 'Unknown flip value')
      end
    end

    context 'with mixed flip types' do
      let(:service_with_mixed_flips) do
        described_class.new(
          attacker_stat: 5,
          defender_stat: 3,
          attacker_flips: '+-',
          defender_flips: ''
        )
      end

      it 'raises error for mixed flip types' do
        expect do
          service_with_mixed_flips.send(:check_consistency_params)
        end.to raise_error(RuntimeError, "You can't mix positive and negative flips")
      end

      it 'raises error for mixed flip types in defender flips' do
        mixed_defender_service = described_class.new(
          attacker_stat: 5,
          defender_stat: 3,
          attacker_flips: '',
          defender_flips: '+-'
        )
        expect do
          mixed_defender_service.send(:check_consistency_params)
        end.to raise_error(RuntimeError, "You can't mix positive and negative flips")
      end
    end

    context 'with simple duel validation' do
      it 'validates simple duel parameters correctly' do
        simple_service = described_class.new(
          attacker_stat: 5,
          target_number: 7,
          attacker_flips: '',
          defender_flips: ''
        )
        expect { simple_service.send(:check_consistency_params) }.not_to raise_error
      end

      it 'raises error when neither defender_stat nor target_number is provided' do
        invalid_service = described_class.new(
          attacker_stat: 5,
          attacker_flips: '',
          defender_flips: ''
        )
        expect { invalid_service.call }.to raise_error(RuntimeError, 'Unknown duel type')
      end
    end
  end

  describe '#process_flips' do
    context 'with empty flips' do
      it 'returns correct values' do
        number_of_cards, flip_symbol = service.send(:process_flips, flips: '')
        expect(number_of_cards).to eq(1)
        expect(flip_symbol).to be_nil
      end
    end

    context 'with positive flips' do
      it 'returns correct values for single positive flip' do
        number_of_cards, flip_symbol = service.send(:process_flips, flips: '+')
        expect(number_of_cards).to eq(2)
        expect(flip_symbol).to eq('+')
      end

      it 'returns correct values for multiple positive flips' do
        number_of_cards, flip_symbol = service.send(:process_flips, flips: '++')
        expect(number_of_cards).to eq(3)
        expect(flip_symbol).to eq('+')
      end
    end

    context 'with negative flips' do
      it 'returns correct values for single negative flip' do
        number_of_cards, flip_symbol = service.send(:process_flips, flips: '-')
        expect(number_of_cards).to eq(2)
        expect(flip_symbol).to eq('-')
      end

      it 'returns correct values for multiple negative flips' do
        number_of_cards, flip_symbol = service.send(:process_flips, flips: '--')
        expect(number_of_cards).to eq(3)
        expect(flip_symbol).to eq('-')
      end
    end
  end

  describe '#combinations' do
    it 'returns correct number of combinations for 1 card' do
      combinations = service.send(:combinations, number_of_cards: 1)
      expect(combinations).to be_an(Array)
      expect(combinations.length).to eq(54) # C(54, 1) = 54
    end

    it 'returns correct number of combinations for 2 cards' do
      combinations = service.send(:combinations, number_of_cards: 2)
      expect(combinations).to be_an(Array)
      expect(combinations.length).to eq(1431) # C(54, 2) = 1431
    end

    it 'returns correct number of combinations for 3 cards' do
      combinations = service.send(:combinations, number_of_cards: 3)
      expect(combinations).to be_an(Array)
      expect(combinations.length).to eq(24_804) # C(54, 3) = 24804
    end

    it 'returns empty array for invalid number of cards' do
      combinations = service.send(:combinations, number_of_cards: -1)
      expect(combinations).to eq([])
    end
  end

  describe '#determine_draw_value' do
    context 'with single card' do
      it 'returns the card value' do
        value = service.send(:determine_draw_value, cards: [7], flip_symbol: nil)
        expect(value).to eq(7)
      end

      it 'returns the card value for edge cases' do
        value = service.send(:determine_draw_value, cards: [0], flip_symbol: nil)
        expect(value).to eq(0)

        value = service.send(:determine_draw_value, cards: [14], flip_symbol: nil)
        expect(value).to eq(14)
      end
    end

    context 'with black joker' do
      it 'returns 0 when black joker is present' do
        value = service.send(:determine_draw_value, cards: [0, 5], flip_symbol: '+')
        expect(value).to eq(0)
      end

      it 'returns 0 even with multiple cards' do
        value = service.send(:determine_draw_value, cards: [0, 5, 10], flip_symbol: '+')
        expect(value).to eq(0)
      end
    end

    context 'with red joker' do
      it 'returns 14 when red joker is present' do
        value = service.send(:determine_draw_value, cards: [14, 3], flip_symbol: '-')
        expect(value).to eq(14)
      end

      it 'returns 14 even with multiple cards' do
        value = service.send(:determine_draw_value, cards: [14, 3, 8], flip_symbol: '-')
        expect(value).to eq(14)
      end
    end

    context 'with positive flip' do
      it 'returns the maximum value' do
        value = service.send(:determine_draw_value, cards: [3, 7, 2], flip_symbol: '+')
        expect(value).to eq(7)
      end

      it 'returns the maximum value for edge cases' do
        value = service.send(:determine_draw_value, cards: [1, 13], flip_symbol: '+')
        expect(value).to eq(13)
      end
    end

    context 'with negative flip' do
      it 'returns the minimum value' do
        value = service.send(:determine_draw_value, cards: [3, 7, 2], flip_symbol: '-')
        expect(value).to eq(2)
      end

      it 'returns the minimum value for edge cases' do
        value = service.send(:determine_draw_value, cards: [1, 13], flip_symbol: '-')
        expect(value).to eq(1)
      end
    end

    context 'with multiple cards without flip' do
      it 'raises error for inconsistent params' do
        expect do
          service.send(:determine_draw_value, cards: [3, 7], flip_symbol: nil)
        end.to raise_error(RuntimeError, 'Inconsistent params')
      end

      it 'raises error for many cards without flip' do
        expect do
          service.send(:determine_draw_value, cards: [3, 7, 10], flip_symbol: nil)
        end.to raise_error(RuntimeError, 'Inconsistent params')
      end
    end
  end

  describe '#process_combinations' do
    context 'with attacker flips' do
      let(:service_with_attacker_flips) do
        described_class.new(
          attacker_stat: 5,
          defender_stat: 3,
          attacker_flips: '++',
          defender_flips: ''
        )
      end

      it 'processes attacker flips correctly' do
        result = service_with_attacker_flips.send(:process_combinations, flips: '++')
        expect(result).to be_an(Array)
        expect(result).to all(be_an(Integer))
        expect(result.length).to eq(24_804) # C(54, 3) = 24804
      end
    end

    context 'with defender flips' do
      let(:service_with_defender_flips) do
        described_class.new(
          attacker_stat: 5,
          defender_stat: 3,
          attacker_flips: '',
          defender_flips: '--'
        )
      end

      it 'processes defender flips correctly' do
        result = service_with_defender_flips.send(:process_combinations, flips: '--')
        expect(result).to be_an(Array)
        expect(result).to all(be_an(Integer))
        expect(result.length).to eq(24_804) # C(54, 3) = 24804
      end
    end

    context 'with no flips' do
      it 'processes no flips correctly' do
        result = service.send(:process_combinations, flips: '')
        expect(result).to be_an(Array)
        expect(result).to all(be_an(Integer))
        expect(result.length).to eq(54) # C(54, 1) = 54
      end
    end

    context 'with single flip' do
      it 'processes single flip correctly' do
        result = service.send(:process_combinations, flips: '+')
        expect(result).to be_an(Array)
        expect(result).to all(be_an(Integer))
        expect(result.length).to eq(1431) # C(54, 2) = 1431
      end
    end
  end

  describe '#simple_duel_results' do
    let(:simple_service) do
      described_class.new(
        attacker_stat: 5,
        target_number: 7,
        attacker_flips: '',
        defender_flips: ''
      )
    end

    it 'returns array of results for simple duel' do
      results = simple_service.send(:simple_duel_results)
      expect(results).to be_an(Array)
      expect(results).to all(be_an(Integer))
      expect(results.length).to eq(54) # C(54, 1) = 54
    end

    context 'with flips' do
      let(:simple_service_with_flips) do
        described_class.new(
          attacker_stat: 5,
          target_number: 7,
          attacker_flips: '++',
          defender_flips: ''
        )
      end

      it 'returns array of results for simple duel with flips' do
        results = simple_service_with_flips.send(:simple_duel_results)
        expect(results).to be_an(Array)
        expect(results).to all(be_an(Integer))
        expect(results.length).to eq(24_804) # C(54, 3) = 24804
      end
    end

    context 'with edge case target numbers' do
      it 'handles very low target numbers' do
        low_target_service = described_class.new(
          attacker_stat: 5,
          target_number: 1,
          attacker_flips: '',
          defender_flips: ''
        )
        results = low_target_service.send(:simple_duel_results)
        expect(results).to all(be >= 0) # Should all be successes
      end

      it 'handles very high target numbers' do
        high_target_service = described_class.new(
          attacker_stat: 5,
          target_number: 20,
          attacker_flips: '',
          defender_flips: ''
        )
        results = high_target_service.send(:simple_duel_results)
        expect(results).to all(be < 0) # Should all be failures
      end
    end
  end

  describe '#opposed_duel_results' do
    it 'returns array of results for opposed duel' do
      results = service.send(:opposed_duel_results)
      expect(results).to be_an(Array)
      expect(results).to all(be_an(Integer))
      expect(results.length).to eq(54 * 54) # 54 * 54 = 2916
    end

    context 'with target number' do
      let(:service_with_target) do
        described_class.new(
          attacker_stat: 5,
          defender_stat: 3,
          target_number: 8,
          attacker_flips: '',
          defender_flips: ''
        )
      end

      it 'applies target number penalty' do
        results = service_with_target.send(:opposed_duel_results)
        expect(results).to be_an(Array)
        expect(results).to all(be_an(Integer))
        expect(results.length).to eq(54 * 54) # 54 * 54 = 2916
      end
    end

    context 'with flips' do
      let(:service_with_flips) do
        described_class.new(
          attacker_stat: 5,
          defender_stat: 3,
          attacker_flips: '++',
          defender_flips: '--'
        )
      end

      it 'returns array of results for opposed duel with flips' do
        results = service_with_flips.send(:opposed_duel_results)
        expect(results).to be_an(Array)
        expect(results).to all(be_an(Integer))
        expect(results.length).to eq(24_804 * 24_804) # C(54,3) * C(54,3) = 24804 * 24804
      end
    end

    context 'with edge case stats' do
      it 'handles very low stats' do
        low_stat_service = described_class.new(
          attacker_stat: 1,
          defender_stat: 1,
          attacker_flips: '',
          defender_flips: ''
        )
        results = low_stat_service.send(:opposed_duel_results)
        expect(results).to be_an(Array)
        expect(results).to all(be_an(Integer))
      end

      it 'handles very high stats' do
        high_stat_service = described_class.new(
          attacker_stat: 20,
          defender_stat: 20,
          attacker_flips: '',
          defender_flips: ''
        )
        results = high_stat_service.send(:opposed_duel_results)
        expect(results).to be_an(Array)
        expect(results).to all(be_an(Integer))
      end
    end
  end

  describe 'integration scenarios' do
    context 'with complex flips' do
      let(:complex_service) do
        described_class.new(
          attacker_stat: 8,
          defender_stat: 6,
          attacker_flips: '++',
          defender_flips: '--'
        )
      end

      it 'calculates success rate for complex scenario' do
        result = complex_service.call
        expect(result).to be_a(Hash)
        expect(result[:global_success_rate]).to be_between(0, 100)
        expect(result[:global_success_rate_with_raise]).to be_between(0, 100)
      end
    end

    context 'with attacker advantage' do
      let(:attacker_advantage_service) do
        described_class.new(
          attacker_stat: 10,
          defender_stat: 5,
          attacker_flips: '',
          defender_flips: ''
        )
      end

      it 'gives high success rate for attacker advantage' do
        result = attacker_advantage_service.call
        # With attacker having +5 advantage, success rate should be high
        expect(result[:global_success_rate]).to be > 50
      end
    end

    context 'with defender advantage' do
      let(:defender_advantage_service) do
        described_class.new(
          attacker_stat: 3,
          defender_stat: 8,
          attacker_flips: '',
          defender_flips: ''
        )
      end

      it 'gives low success rate for defender advantage' do
        result = defender_advantage_service.call
        # With defender having +5 advantage, success rate should be low
        expect(result[:global_success_rate]).to be < 50
      end
    end

    context 'with simple duel and flips' do
      let(:simple_duel_with_flips) do
        described_class.new(
          attacker_stat: 6,
          target_number: 8,
          attacker_flips: '++',
          defender_flips: ''
        )
      end

      it 'calculates success rate for simple duel with flips' do
        result = simple_duel_with_flips.call
        expect(result).to be_a(Hash)
        expect(result[:global_success_rate]).to be_between(0, 100)
        expect(result[:global_success_rate_with_raise]).to be_between(0, 100)
      end
    end
  end
end
