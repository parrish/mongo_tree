module MongoTree
  module Strategies
    module FullTreeNode
      include MongoTree::Base
      
      def self.included(base)
        base.class_eval do
          class << self
            attr_accessor :mongo_tree_options
          end
          
          @mongo_tree_options = {
            :root => "#{self.name}".sub(/Node/, '')
          }.merge(@mongo_tree_options)
          
          many :children, :class_name => self.name
        end
        
        base.extend ClassMethods
        base.send :include, InstanceMethods
      end
      
      module ClassMethods
      end
      
      module InstanceMethods
        def root
          self._root_document
        end

        def parent
          self._parent_document
        end
        
        def parent=(target)
          bson = root_class.collection.find_one(root.id)
          my_bson = nil
          
          modify_children(bson, self) do |parent, found|
            my_bson = found
            parent['children'].delete(found)
          end
          
          modify_children(bson, target) do |parent, found|
            found['children'] << my_bson
          end
          
          root_class.collection.update({'_id' => root.id}, bson)
          root.reload
        end

        def siblings
          self._parent_document.children.reject{ |n| n.id == self.id }
        end

        def ancestors
          collected = []
          current = parent

          until current == root
            collected.unshift(current)
            current = current.parent
          end

          collected.unshift(root)
        end
        
        protected
        def root_class
          self.class.mongo_tree_options[:root].to_s.constantize
        end
        
        def modify_children(tree, node, &block)
          current = tree
          found = nil
          
          ancestors = node.ancestors
          ancestors.shift

          until ancestors.empty?
            ancestor = ancestors.shift
            current = current['children'].select{ |child| child['_id'] == ancestor['_id'] }.first
          end
          
          if current['_id'] == node.id
            found = current
          else
            found = current['children'].select{ |child| child['_id'] == node.id }.first
          end
          
          yield(current, found)
          return tree
        end
      end
    end
  end
end