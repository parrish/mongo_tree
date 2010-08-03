module MongoTree
  module Strategies
    module FullTreeRoot
      include MongoTree::Base
      
      def self.included(base)
        base.class_eval do
          class << self
            attr_accessor :mongo_tree_options
          end
          
          @mongo_tree_options = {
            :embeds => "#{self.name}Node"
          }.merge(@mongo_tree_options)
          
          many :children, :class_name => @mongo_tree_options[:embeds].to_s
        end
        
        base.extend ClassMethods
        base.send :include, InstanceMethods
      end
      
      module ClassMethods
        def roots
          self.all
        end
      end
      
      module InstanceMethods
        def depth
          0
        end

        def parent
          nil
        end

        def siblings
          []
        end

        def ancestors
          []
        end
      end
    end
  end
end