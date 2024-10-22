module Papyrus
  class ObjectConverter
    class << self
      def serialize(params)
        ::JSON.load(::JSON.dump(serialize_v(params)))
      end

      def serialize_v(v)
        if v.is_a?(ActiveRecord::Base)
          {type: v.class.name, id: v.id}
        elsif v.is_a?(Hash)
          {type: v.class.name, obj: v.transform_values { |va| serialize_v(va) }}
        elsif v.is_a?(Array)
          v.map! { |va| serialize_v(va) }
        else
          v
        end
      end

      def deserialize(params)
        deserialize_v(params)
      end

      def deserialize_v(v)
        if v.is_a?(Hash)
          if v.key?('id')
            v['type'].safe_constantize&.find(v['id'])
          else
            v['obj'].transform_values { |va| deserialize_v(va) }.with_indifferent_access
          end
        elsif v.is_a?(Array)
          v.map! { |va| deserialize_v(va) }
        else
          v
        end
      end
    end
  end
end
