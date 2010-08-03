module MongoTree
  module Strategies
    module ChildLink
      include MongoTree::Base
      
      def self.included(base)
        base.class_eval do
          key :child_id, ObjectId, :index => true
          many :children, :class_name => self.name, :foreign_key => "child_id"
        end
        
        base.extend ClassMethods
        base.send :include, InstanceMethods
      end
      
      module ClassMethods
        def roots
          self.all(:child_id => nil)
        end
      end
      
      module InstanceMethods
        def parent
          @parent ||= self.class.find(self.child_id)
        end

        def parent=(node)
          @parent = node
          self.child_id = node.id
          save if changed?
        end

        def siblings
          return nil if parent.nil?
          parent.children.reject{ |node| node == self }
        end
        
        def descendants
          collected = []
          nodes = self.children

          until nodes.empty?
            current = nodes.shift
            collected << current
            nodes += current.children
          end

          collected
        end
      end
    end
  end
end