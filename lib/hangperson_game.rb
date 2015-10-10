class HangpersonGame

  # add the necessary class methods, attributes, etc. here
  # to make the tests in spec/hangperson_game_spec.rb pass.
  
  # Get a word from remote "random word" service

  # def initialize()
  # end
  
  attr_accessor :word, :guesses, :wrong_guesses
  
  def initialize(word)
    @word = word
    @working_word = word.clone
    @guesses = ''
    @wrong_guesses = ''
  end

  def self.get_random_word
    require 'uri'
    require 'net/http'
    uri = URI('http://watchout4snakes.com/wo4snakes/Random/RandomWord')
    Net::HTTP.post_form(uri ,{}).body
  end

  def guess(letter)
    raise ArgumentError if letter.nil?
    raise ArgumentError if letter.empty?
    raise ArgumentError if (letter =~ /[^a-zA-Z]/)
    letter.downcase!
    if @guesses.include? letter or @wrong_guesses.include? letter
      # repeated guess
      return false;
    else
      if @working_word.include? letter
        @guesses << letter
        @working_word.delete! letter
      else
        @wrong_guesses << letter
      end
      return true
    end
  end

  def word_with_guesses
    result = ''
    @word.split('').each { |letter|
      if @guesses.include? letter
        result << letter
      else
        result << '-'
      end
    }
    return result
  end
  
  def check_win_or_lose
    if @working_word.empty?
      return :win
    else
      if @wrong_guesses.size == 7
        return :lose
      else
        return :play
      end
    end
  end
end

