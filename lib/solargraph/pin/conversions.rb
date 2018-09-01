module Solargraph
  module Pin
    # @todo Move this stuff. It should be the responsibility of the language server.
    module Conversions
      # @return [Hash]
      def completion_item
        @completion_item ||= {
          label: name,
          kind: completion_item_kind,
          detail: detail,
          data: {
            path: path,
            return_type: return_type,
            location: (location ? location.to_hash : nil),
            deprecated: deprecated?
          }
        }
      end

      # @return [Hash]
      def resolve_completion_item
        if @resolve_completion_item.nil?
          extra = {}
          alldoc = ''
          alldoc += link_documentation unless link_documentation.nil?
          alldoc += "\n\n" unless alldoc.empty?
          alldoc += documentation unless documentation.nil?
          extra[:documentation] = alldoc unless alldoc.empty?
          @resolve_completion_item = completion_item.merge(extra)
        end
        @resolve_completion_item
      end

      # @return [Hash]
      def signature_help
        @signature_help ||= {
          label: name + '(' + parameters.join(', ') + ')',
          documentation: documentation
        }
      end

      # @return [String]
      def detail
        if @detail.nil?
          @detail = ''
          @detail += "(#{parameters.join(', ')}) " unless kind != Pin::METHOD or parameters.empty?
          @detail += "=> #{return_complex_type.tag}" unless return_complex_type.undefined?
          @detail.strip!
        end
        return nil if @detail.empty?
        @detail
      end

      # Get a markdown-flavored link to a documentation page.
      #
      # @return [String]
      def link_documentation
        @link_documentation ||= generate_link
      end

      def reset_conversions
        @completion_item = nil
        @resolve_completion_item = nil
        @signature_help = nil
        @detail = nil
        @link_documentation = nil
      end

      private

      def generate_link
        return nil if return_complex_type.undefined?
        this_path = path || return_type
        return nil if this_path.nil?
        "[#{this_path.gsub('_', '\\\\_')}](solargraph:/document?query=#{URI.encode(this_path)})"
      end
    end
  end
end
