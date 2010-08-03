module MongoTree
  class Children < Array
    def initialize(array, parent, &update_method)
      @parent = parent
      @update_method = block_given? ? update_method : Proc.new { |child, parent| child.parent_id = parent.id }
      super(array)
    end
  
    def <<(*docs)
      @parent.save if @parent.new?
      flatten_deeper(docs).collect do |doc|
        @update_method.call(doc, @parent)
        doc.save if doc.changed? || doc.new?
      end
    
      super.uniq
    end
    alias_method :push, :<<
    alias_method :concat, :<<
  
    private
    def flatten_deeper(docs)
      docs.collect{ |doc| (doc.respond_to?(:flatten) && !doc.is_a?(Hash)) ? doc.flatten : doc }.flatten
    end
  end
end