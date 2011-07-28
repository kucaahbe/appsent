class Hash
  # fix  bug here
  unless self.method_defined?(:symbolize_keys!)
    def symbolize_keys!
      self.keys.each { |key| self[(key.to_sym rescue key) || key] = self.delete(key) }
    end
  end
end
