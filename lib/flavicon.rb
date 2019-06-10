# frozen_string_literal: true

module Flavicon
  autoload :Finder, 'flavicon/finder'

  def self.find(url)
    Finder.new(url).find
  end
end
