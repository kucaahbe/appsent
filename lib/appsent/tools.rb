class Hash
  unless self.respond_to?(:symbolize_keys!)
    def symbolize_keys!
      self.keys.each { |key| self[(key.to_sym rescue key) || key] = self.delete(key) }
    end
  end
end
