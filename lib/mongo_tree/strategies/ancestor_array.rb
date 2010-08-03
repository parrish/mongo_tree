module MongoTree
  module Strategies
    module AncestorArray
      include MongoTree::Base
      
      def self.included(base)
        base.class_eval do
          class << self
            attr_accessor :mongo_tree_options
          end
          
          @mongo_tree_options = { :path_attribute => :id }.merge(@mongo_tree_options)
          
          key :parent_id, ObjectId
          key :ancestor_ids, Array, :index => true
          belongs_to :parent, :class_name => self.name
          before_save :update_ancestors, :if => Proc.new{ |doc| doc.changes.has_key? "parent_id" }
          after_save :update_children, :if => Proc.new{ |doc| doc.changes.has_key? "parent_id" }
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
        def root
          self.class.first(path_attribute => self.ancestor_ids.first)
        end

        def depth
          ancestor_ids.length
        end

        def siblings
          self.class.all(:parent_id => self.parent_id, path_attribute.ne => self.send(path_attribute))
        end

        def ancestors
          self.ancestor_ids.map{ |id| self.class.first(path_attribute => id) }
        end

        def descendants
          self.class.all(:ancestor_ids.all => self.ancestor_ids << self.send(path_attribute))
        end

        protected
        def update_ancestors
          self.ancestor_ids = []
          current = self

          until current.parent.nil?
            self.ancestor_ids.unshift(current.parent.send(path_attribute))
            current = current.parent
          end
        end

        def update_children
          self.class.all(:parent_id => self.id).map do |child|
            child.instance_eval{ update_ancestors }
            child.save
          end
        end
        
        def path_attribute
          self.class.mongo_tree_options[:path_attribute].to_sym
        end
      end
    end
  end
end