module MongoTree
  module Strategies
    module ParentLink
      include MongoTree::Base
      
      def self.included(base)
        base.class_eval do
          key :parent_id, ObjectId, :index => true
          belongs_to :parent, :class_name => self.name
        end
        
        base.extend ClassMethods
        base.send :include, InstanceMethods
      end
      
      module ClassMethods
        def roots
          self.all(:parent_id => nil)
        end
      end
      
      module InstanceMethods
        def siblings
          self.class.all(:parent_id => self.parent_id, :id.ne => self.id)
        end
        
        def descendants
          collected = []
          nodes = [self]

          until nodes.empty?
            current = nodes.shift
            current_children = self.class.all(:parent_id => current.id)
            nodes += current_children
            collected += current_children
          end

          collected
        end
      end
    end
  end
end