require "json"

class Deck
  def draw_tarot(number_of_cards = 1)
    tarot_path = File.expand_path(File.dirname(__FILE__)).concat("/../data/tarot.json")
    tarot_file = File.open(tarot_path, "r")
    tarot_data = JSON.load(tarot_file)
    
    card_array = tarot_data.sample(number_of_cards)
    
    tarot_file.close
    return card_array
  end

  def draw_playing_card(number_of_cards = 1)
    deck = instantiate_playing_card_deck
    return deck.sample(number_of_cards)
  end

  private

  def instantiate_playing_card_deck
    deck = []
    values = ["Ace", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Jack", "Queen", "King"]
    suits = ["Diamonds", "Clubs", "Hearts", "Spades"]
    
    suits.each do |d|
      values.each do |v|
        deck.push("#{v} of #{d}")
      end
    end

    return deck
  end
end