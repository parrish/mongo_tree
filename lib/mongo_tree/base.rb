module MongoTree
  module Base
    def self.included(base)
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
        current = self

        until current.parent.nil?
          current = current.parent
        end

        current
      end
      
      def depth
        ancestors.length
      end
      
      def children
        MongoTree::Children.new(self.class.all(:parent_id => self.id), self)
      end
      
      def children=(nodes)
        nodes.each{ |node| children << node }
      end
      
      def ancestors
        collected = []
        current = self.parent

        until current.nil?
          collected << current
          current = current.parent
        end

        collected
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
