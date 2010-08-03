module MongoTree
  module Strategies
    module MaterializedPath
      include MongoTree::Base
      
      def self.included(base)
        base.class_eval do
          class << self
            attr_accessor :mongo_tree_options
          end
          
          @mongo_tree_options = {
            :path_attribute => :id,
            :path_delimiter => ','
          }.merge(@mongo_tree_options)
          
          key :path, String, :index => true
          key :depth, Integer, :default => 0
          validates_presence_of @mongo_tree_options[:path_attribute].to_sym
          before_save :update_path_and_depth, :if => Proc.new{ |doc| doc.changes.has_key? "path" }
          after_save :update_children, :if => Proc.new{ |doc| doc.changes.has_key? "path" }
        end
        
        base.extend ClassMethods
        base.send :include, InstanceMethods
      end
      
      module ClassMethods
        def roots
          self.all(:depth => 0)
        end
      end
      
      module InstanceMethods
        def path
          if self[:path].nil?
            self.send(path_attribute).to_s
          else
            self[:path]
          end
        end

        def root
          find_by_path_attribute(path_array.first)
        end

        def parent
          @parent ||= find_parent_from_path
        end

        def parent=(node)
          @parent = node
          update_path_and_depth
        end

        def children
          docs = self.class.all(:path => /^#{ self.path },/, :depth => self.depth + 1)
          MongoTree::Children.new(docs, self) do |child, parent|
            child.parent = parent
          end
        end

        def siblings
          return [] if @parent.nil?
          self.class.all(:path => /^#{ @parent.path },/, :depth => self.depth, path_attribute.ne => self.send(path_attribute).to_s)
        end

        def ancestors
          return [] if self.path.nil?
          path_array[0..-2].map{ |n| find_by_path_attribute(n) }
        end

        def descendants
          return [] if self.path.nil?
          self.class.all(:path => /^#{ self.path },/)
        end

        protected
        def path_attribute
          self.class.mongo_tree_options[:path_attribute].to_sym
        end
        
        def path_delimiter
          self.class.mongo_tree_options[:path_delimiter].to_s
        end
        
        def path_array
          self.path.split(path_delimiter)
        end

        def find_by_path_attribute(id)
          self.class.first(path_attribute => id)
        end

        def find_parent_from_path
          return nil if self.path.nil? || self.path.length < 2
          @parent = find_by_path_attribute(path_array[-2])
        end

        def update_path_and_depth
          @parent ||= find_parent_from_path
          self.path = @parent.nil? ? send(path_attribute).to_s : "#{ @parent.path }#{ path_delimiter }#{ send(path_attribute).to_s }"
          self.depth = path_array.length - 1
        end

        def update_children
          old_path = self.changes['path'].first
          old_depth = self.changes.has_key?('depth') ? self.changes['depth'].first : self.depth
          return if old_path.nil? || old_depth.nil?

          self.class.all(:path => /^#{ old_path },/, :depth => old_depth + 1).map do |child|
            child.instance_eval{ update_path_and_depth }
            child.save
          end
        end
      end
    end
  end
end
