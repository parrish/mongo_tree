module MongoTree
  autoload :Children, 'mongo_tree/children'
  
  module ClassMethods
    def acts_as_tree(strategy, options = {})
      @mongo_tree_options = options
      
      case strategy
      when :full_tree
        if options.has_key?(:embeds)
          self.send :include, MongoTree::Strategies::FullTreeRoot
        elsif options.has_key?(:root)
          self.send :include, MongoTree::Strategies::FullTreeNode
        else
          raise 'The full_tree strategy needs to have either the :root or the :embeds class specified'
        end
      when :child_link
        self.send :include, MongoTree::Strategies::ChildLink
      when :parent_link
        self.send :include, MongoTree::Strategies::ParentLink
      when :ancestor_array
        self.send :include, MongoTree::Strategies::AncestorArray
      when :materialized_path
        self.send :include, MongoTree::Strategies::MaterializedPath
      else
        # I guess this is an okay default?
        self.send :include, MongoTree::Strategies::ParentLink
      end
    end
  end
  
  module Strategies
    autoload :FullTreeRoot,       'mongo_tree/strategies/full_tree_root'
    autoload :FullTreeNode,       'mongo_tree/strategies/full_tree_node'
    autoload :ChildLink,          'mongo_tree/strategies/child_link'
    autoload :ParentLink,         'mongo_tree/strategies/parent_link'
    autoload :AncestorArray,      'mongo_tree/strategies/ancestor_array'
    autoload :MaterializedPath,   'mongo_tree/strategies/materialized_path'
  end
end

MongoMapper::Plugins.send :include, MongoTree