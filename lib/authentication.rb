module Authentication
  mattr_accessor :config

  self.config = ActiveSupport::OrderedOptions.new

  def self.configure
    yield(config) if block_given?
  end
end
