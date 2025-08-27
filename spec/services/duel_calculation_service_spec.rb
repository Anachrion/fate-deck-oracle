require 'spec_helper'

RSpec.describe DuelCalculationService do
  let(:service) do
    described_class.new(
      attacker_stat: 5,
      defender_stat: 3,
      attacker_flips: [],
      defender_flips: []
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
      expect(service.attacker_flips).to eq([])
      expect(service.defender_flips).to eq([])
    end
  end

  describe '#call' do
    context 'with no flips' do
      it 'calculates success rate correctly' do
        result = service.call
        expect(result).to be_a(Float)
        expect(result).to be_between(0.0, 1.0)
      end
    end

    context 'with flips' do
      let(:service_with_flips) do
        described_class.new(
          attacker_stat: 5,
          defender_stat: 3,
          attacker_flips: [:+, :+],
          defender_flips: [:-]
        )
      end

      it 'calculates success rate with flips' do
        result = service_with_flips.call
        expect(result).to be_a(Float)
        expect(result).to be_between(0.0, 1.0)
      end
    end
  end

  describe '#check_flips_consistency' do
    context 'with empty flips' do
      it 'returns correct values' do
        number_of_cards, flip_symbol = service.send(:check_flips_consistency, flips: [])
        expect(number_of_cards).to eq(1)
        expect(flip_symbol).to be_nil
      end
    end

    context 'with positive flips' do
      let(:service_with_positive_flips) do
        described_class.new(
          attacker_stat: 5,
          defender_stat: 3,
          attacker_flips: [:+, :+],
          defender_flips: []
        )
      end

      it 'returns correct values' do
        number_of_cards, flip_symbol = service_with_positive_flips.send(:check_flips_consistency, flips: [:+, :+])
        expect(number_of_cards).to eq(3)
        expect(flip_symbol).to eq(:+)
      end
    end

    context 'with negative flips' do
      let(:service_with_negative_flips) do
        described_class.new(
          attacker_stat: 5,
          defender_stat: 3,
          attacker_flips: [:-],
          defender_flips: []
        )
      end

      it 'returns correct values' do
        number_of_cards, flip_symbol = service_with_negative_flips.send(:check_flips_consistency, flips: [:-])
        expect(number_of_cards).to eq(2)
        expect(flip_symbol).to eq(:-)
      end
    end

    context 'with invalid flip values' do
      let(:service_with_invalid_flips) do
        described_class.new(
          attacker_stat: 5,
          defender_stat: 3,
          attacker_flips: [:invalid],
          defender_flips: []
        )
      end

      it 'raises error for unknown flip values' do
        expect {
          service_with_invalid_flips.send(:check_flips_consistency, flips: [:invalid])
        }.to raise_error(RuntimeError, 'Unknown flip value')
      end
    end

    context 'with mixed flip types' do
      let(:service_with_mixed_flips) do
        described_class.new(
          attacker_stat: 5,
          defender_stat: 3,
          attacker_flips: [:+, :-],
          defender_flips: []
        )
      end

      it 'raises error for mixed flip types' do
        expect {
          service_with_mixed_flips.send(:check_flips_consistency, flips: [:+, :-])
        }.to raise_error(RuntimeError, "You can't mix positive and negative flips")
      end
    end
  end

  describe '#combinations' do
    it 'returns correct number of combinations for 2 cards' do
      combinations = service.send(:combinations, number_of_cards: 2)
      expect(combinations).to be_an(Array)
      expect(combinations.length).to eq(1431) # C(54, 2) = 1431
    end

    it 'returns correct number of combinations for 3 cards' do
      combinations = service.send(:combinations, number_of_cards: 3)
      expect(combinations).to be_an(Array)
      expect(combinations.length).to eq(24804) # C(54, 3) = 24804
    end
  end

  describe '#determine_draw_value' do
    context 'with single card' do
      it 'returns the card value' do
        value = service.send(:determine_draw_value, cards: [7], flip: nil)
        expect(value).to eq(7)
      end
    end

    context 'with black joker' do
      it 'returns 0' do
        value = service.send(:determine_draw_value, cards: [0, 5], flip: :+)
        expect(value).to eq(0)
      end
    end

    context 'with red joker' do
      it 'returns 14' do
        value = service.send(:determine_draw_value, cards: [14, 3], flip: :-)
        expect(value).to eq(14)
      end
    end

    context 'with positive flip' do
      it 'returns the maximum value' do
        value = service.send(:determine_draw_value, cards: [3, 7, 2], flip: :+)
        expect(value).to eq(7)
      end
    end

    context 'with negative flip' do
      it 'returns the minimum value' do
        value = service.send(:determine_draw_value, cards: [3, 7, 2], flip: :-)
        expect(value).to eq(2)
      end
    end

    context 'with multiple cards without flip' do
      it 'raises error for inconsistent params' do
        expect {
          service.send(:determine_draw_value, cards: [3, 7], flip: nil)
        }.to raise_error(RuntimeError, 'Inconsistent params')
      end
    end
  end

  describe '#process_combinations' do
    context 'with attacker flips' do
      let(:service_with_attacker_flips) do
        described_class.new(
          attacker_stat: 5,
          defender_stat: 3,
          attacker_flips: [:+, :+],
          defender_flips: []
        )
      end

      it 'processes attacker flips correctly' do
        result = service_with_attacker_flips.send(:process_combinations, flips: [:+, :+])
        expect(result).to be_an(Array)
        expect(result).to all(be_an(Integer))
      end
    end

    context 'with defender flips' do
      let(:service_with_defender_flips) do
        described_class.new(
          attacker_stat: 5,
          defender_stat: 3,
          attacker_flips: [],
          defender_flips: [:-]
        )
      end

      it 'processes defender flips correctly' do
        result = service_with_defender_flips.send(:process_combinations, flips: [:-])
        expect(result).to be_an(Array)
        expect(result).to all(be_an(Integer))
      end
    end
  end

  describe 'integration scenarios' do
    context 'with complex flips' do
      let(:complex_service) do
        described_class.new(
          attacker_stat: 8,
          defender_stat: 6,
          attacker_flips: [:+, :+],
          defender_flips: [:-]
        )
      end

      it 'calculates success rate for complex scenario' do
        result = complex_service.call
        expect(result).to be_a(Float)
        expect(result).to be_between(0.0, 1.0)
      end
    end

    context 'with attacker advantage' do
      let(:attacker_advantage_service) do
        described_class.new(
          attacker_stat: 10,
          defender_stat: 5,
          attacker_flips: [],
          defender_flips: []
        )
      end

      it 'gives high success rate for attacker advantage' do
        result = attacker_advantage_service.call
        # With attacker having +5 advantage, success rate should be high
        expect(result).to be > 0.5
      end
    end

    context 'with defender advantage' do
      let(:defender_advantage_service) do
        described_class.new(
          attacker_stat: 3,
          defender_stat: 8,
          attacker_flips: [],
          defender_flips: []
        )
      end

      it 'gives low success rate for defender advantage' do
        result = defender_advantage_service.call
        # With defender having +5 advantage, success rate should be low
        expect(result).to be < 0.5
      end
    end
  end
end
